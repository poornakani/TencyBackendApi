using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using TenzyBackend.Data.SupplyChain;
using TenzyBackend.Models.SupplyChainModels;

namespace TenzyBackend.Core.Services.SupplyChainService
{
    public class SupplyChainService : ISupplyChainService
    {
        private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

        private readonly ISupplyChainReader _reader;
        private readonly ISupplyChainWriter _writer;

        public SupplyChainService(ISupplyChainReader reader, ISupplyChainWriter writer)
        {
            _reader = reader;
            _writer = writer;
        }

        public Task<SupplyChainDashboardModel> GetDashboardAsync() => _reader.GetDashboardAsync();

        public Task<List<SupplyProcurementListItemModel>> GetProcurementsAsync() => _reader.GetProcurementsAsync();

        public async Task<SupplyProcurementModel> GetProcurementByIdAsync(int procurementId)
        {
            if (procurementId <= 0) throw new ValidationException("Invalid procurement id.");
            return await _reader.GetProcurementByIdAsync(procurementId) ?? throw new NotFoundException("Procurement record not found.");
        }

        public async Task<int> SaveProcurementAsync(SaveProcurementRequest request, Guid userId)
        {
            if (string.IsNullOrWhiteSpace(request.ShopName))
                throw new ValidationException("Shop name is required.");
            if (string.IsNullOrWhiteSpace(request.InvoiceReference))
                throw new ValidationException("Invoice or receipt reference is required.");
            if (!request.Items.Any())
                throw new ValidationException("At least one procurement item is required.");

            var preparedItems = request.Items.Select((item, index) =>
            {
                if (string.IsNullOrWhiteSpace(item.ProductName))
                    throw new ValidationException("Each item requires a product name.");
                if (item.Quantity <= 0)
                    throw new ValidationException($"Quantity for '{item.ProductName}' must be greater than zero.");
                if (item.UnitPrice <= 0)
                    throw new ValidationException($"Unit price for '{item.ProductName}' must be greater than zero.");

                var grossTotal = RoundMoney(item.Quantity * item.UnitPrice);
                return new PreparedProcurementItem
                {
                    LineNumber = index + 1,
                    ProductId = item.ProductId,
                    ProductName = item.ProductName.Trim(),
                    BrandName = (item.BrandName ?? string.Empty).Trim(),
                    CategoryName = (item.CategoryName ?? string.Empty).Trim(),
                    Quantity = item.Quantity,
                    UnitPrice = RoundMoney(item.UnitPrice),
                    GrossTotal = grossTotal,
                    DiscountTotal = 0,
                    NetTotal = grossTotal,
                    NetUnitCost = RoundMoney(grossTotal / item.Quantity),
                    BatchNote = string.IsNullOrWhiteSpace(item.BatchNote) ? null : item.BatchNote.Trim(),
                };
            }).ToList();

            var preparedDiscounts = PrepareDiscounts(request, preparedItems);
            RecalculateNetCosts(preparedItems);

            var sanitizedRequest = new SaveProcurementRequest
            {
                ProcurementId = request.ProcurementId,
                ProcurementReference = NormalizeCode(request.ProcurementReference, "PROC", request.PurchaseDate),
                ShopName = request.ShopName.Trim(),
                PurchaseDate = request.PurchaseDate == default ? DateTime.UtcNow : request.PurchaseDate,
                InvoiceReference = request.InvoiceReference.Trim(),
                PaymentCardName = string.IsNullOrWhiteSpace(request.PaymentCardName) ? null : request.PaymentCardName.Trim(),
                PaymentReference = string.IsNullOrWhiteSpace(request.PaymentReference) ? null : request.PaymentReference.Trim(),
                PurchaseNote = string.IsNullOrWhiteSpace(request.PurchaseNote) ? null : request.PurchaseNote.Trim(),
                Items = request.Items,
                Discounts = request.Discounts,
            };

            var itemsPayload = preparedItems.Select(item => new
            {
                item.LineNumber,
                item.ProductId,
                item.ProductName,
                item.BrandName,
                item.CategoryName,
                item.Quantity,
                item.UnitPrice,
                item.GrossTotal,
                item.DiscountTotal,
                item.NetTotal,
                item.NetUnitCost,
                item.BatchNote,
            }).ToList();

            var discountPayload = preparedDiscounts.Select(discount => new
            {
                discount.DiscountCode,
                discount.DiscountType,
                discount.DiscountScope,
                discount.Description,
                discount.TargetProductName,
                discount.TargetBrandName,
                discount.TargetShopName,
                discount.BuyQuantity,
                discount.PayQuantity,
                discount.Percentage,
                discount.FixedAmount,
                discount.DiscountAmount,
                discount.Notes,
            }).ToList();

            var allocationPayload = preparedDiscounts
                .SelectMany(discount => discount.Allocations.Select(allocation => new
                {
                    discount.DiscountCode,
                    allocation.LineNumber,
                    allocation.Amount,
                }))
                .ToList();

            return await _writer.SaveProcurementAsync(
                sanitizedRequest,
                JsonSerializer.Serialize(itemsPayload, JsonOptions),
                JsonSerializer.Serialize(discountPayload, JsonOptions),
                JsonSerializer.Serialize(allocationPayload, JsonOptions),
                userId);
        }

        public Task<List<SupplyDispatchListItemModel>> GetDispatchesAsync() => _reader.GetDispatchesAsync();

        public async Task<SupplyDispatchModel> GetDispatchByIdAsync(int shipmentId)
        {
            if (shipmentId <= 0) throw new ValidationException("Invalid shipment id.");
            return await _reader.GetDispatchByIdAsync(shipmentId) ?? throw new NotFoundException("Shipment not found.");
        }

        public async Task<int> SaveDispatchAsync(SaveDispatchRequest request, Guid userId)
        {
            if (string.IsNullOrWhiteSpace(request.CourierName))
                throw new ValidationException("Courier name is required.");
            if (string.IsNullOrWhiteSpace(request.ParcelNumber))
                throw new ValidationException("Parcel or shipment number is required.");
            if (!request.Items.Any())
                throw new ValidationException("At least one shipment item is required.");

            foreach (var item in request.Items)
            {
                if (item.ProcurementItemId <= 0)
                    throw new ValidationException("Each shipment item must reference a procurement item.");
                if (item.QuantityDispatched <= 0)
                    throw new ValidationException("Dispatched quantity must be greater than zero.");
            }

            var sanitizedRequest = new SaveDispatchRequest
            {
                ShipmentId = request.ShipmentId,
                DispatchReference = NormalizeCode(request.DispatchReference, "DSP", request.DispatchDate),
                DispatchDate = request.DispatchDate == default ? DateTime.UtcNow : request.DispatchDate,
                CourierName = request.CourierName.Trim(),
                ParcelNumber = request.ParcelNumber.Trim(),
                ShipmentStatus = string.IsNullOrWhiteSpace(request.ShipmentStatus) ? "pending" : request.ShipmentStatus.Trim().ToLowerInvariant(),
                Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
                Items = request.Items,
            };

            return await _writer.SaveDispatchAsync(
                sanitizedRequest,
                JsonSerializer.Serialize(sanitizedRequest.Items, JsonOptions),
                userId);
        }

        public async Task<int> AddShipmentChargeAsync(int shipmentId, AddShipmentChargeRequest request, Guid userId)
        {
            if (shipmentId <= 0) throw new ValidationException("Invalid shipment id.");
            if (string.IsNullOrWhiteSpace(request.ChargeType))
                throw new ValidationException("Charge type is required.");
            if (request.Amount <= 0)
                throw new ValidationException("Charge amount must be greater than zero.");

            var normalizedRequest = new AddShipmentChargeRequest
            {
                ChargeType = request.ChargeType.Trim().ToLowerInvariant(),
                CurrencyCode = string.IsNullOrWhiteSpace(request.CurrencyCode) ? "GBP" : request.CurrencyCode.Trim().ToUpperInvariant(),
                Amount = RoundMoney(request.Amount),
                ChargeDate = request.ChargeDate == default ? DateTime.UtcNow : request.ChargeDate,
                Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
            };

            return await _writer.AddShipmentChargeAsync(shipmentId, normalizedRequest, userId);
        }

        public Task<List<SupplyArrivalListItemModel>> GetArrivalsAsync() => _reader.GetArrivalsAsync();

        public async Task<SupplyArrivalModel> GetArrivalByIdAsync(int arrivalVerificationId)
        {
            if (arrivalVerificationId <= 0) throw new ValidationException("Invalid arrival verification id.");
            return await _reader.GetArrivalByIdAsync(arrivalVerificationId) ?? throw new NotFoundException("Arrival verification not found.");
        }

        public async Task<int> SaveArrivalAsync(SaveArrivalRequest request, Guid userId)
        {
            if (request.ShipmentId <= 0)
                throw new ValidationException("A shipment is required.");
            if (!request.Items.Any())
                throw new ValidationException("At least one arrival item is required.");

            foreach (var item in request.Items)
            {
                if (item.ShipmentItemId <= 0)
                    throw new ValidationException("Each arrival item must reference a shipment item.");
                if (item.QuantityReceived < 0 || item.ApprovedQuantity < 0 || item.MissingQuantity < 0 || item.ExtraQuantity < 0 || item.DamagedQuantity < 0)
                    throw new ValidationException("Arrival quantities cannot be negative.");
            }

            var sanitizedRequest = new SaveArrivalRequest
            {
                ArrivalVerificationId = request.ArrivalVerificationId,
                ShipmentId = request.ShipmentId,
                VerificationDate = request.VerificationDate == default ? DateTime.UtcNow : request.VerificationDate,
                VerificationStatus = string.IsNullOrWhiteSpace(request.VerificationStatus) ? "received" : request.VerificationStatus.Trim().ToLowerInvariant(),
                Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
                Items = request.Items,
            };

            return await _writer.SaveArrivalAsync(
                sanitizedRequest,
                JsonSerializer.Serialize(sanitizedRequest.Items, JsonOptions),
                userId);
        }

        public Task<List<EligiblePricingItemModel>> GetEligiblePricingItemsAsync() => _reader.GetEligiblePricingItemsAsync();

        public Task<List<SupplyPricingModel>> GetPricingAsync() => _reader.GetPricingAsync();

        public async Task<int> SavePricingAsync(SavePricingRequest request, Guid userId)
        {
            if (request.ArrivalItemId <= 0)
                throw new ValidationException("An arrival item is required.");
            if (request.SellingPrice <= 0)
                throw new ValidationException("Selling price must be greater than zero.");
            if (request.CustomerDiscountPercent < 0 || request.CustomerDiscountAmount < 0)
                throw new ValidationException("Discount values cannot be negative.");

            var sanitizedRequest = new SavePricingRequest
            {
                PricingId = request.PricingId,
                ArrivalItemId = request.ArrivalItemId,
                SellingPrice = RoundMoney(request.SellingPrice),
                CustomerDiscountPercent = RoundMoney(request.CustomerDiscountPercent),
                CustomerDiscountAmount = RoundMoney(request.CustomerDiscountAmount),
                PricingNotes = string.IsNullOrWhiteSpace(request.PricingNotes) ? null : request.PricingNotes.Trim(),
                IsApproved = request.IsApproved,
            };

            return await _writer.SavePricingAsync(sanitizedRequest, userId);
        }

        public Task<List<SupplyProcurementReportRowModel>> GetProcurementReportAsync(DateTime? startDate, DateTime? endDate, string? shop, string? brand, string? product, string? category)
            => _reader.GetProcurementReportAsync(startDate, endDate, NormalizeFilter(shop), NormalizeFilter(brand), NormalizeFilter(product), NormalizeFilter(category));

        public Task<List<SupplyDispatchReportRowModel>> GetDispatchReportAsync(DateTime? startDate, DateTime? endDate, string? courier, string? brand, string? product, string? category, string? shipmentStatus)
            => _reader.GetDispatchReportAsync(startDate, endDate, NormalizeFilter(courier), NormalizeFilter(brand), NormalizeFilter(product), NormalizeFilter(category), NormalizeFilter(shipmentStatus));

        public Task<List<SupplyMonthlyDispatchSummaryModel>> GetMonthlyDispatchSummaryAsync(DateTime? startDate, DateTime? endDate)
            => _reader.GetMonthlyDispatchSummaryAsync(startDate, endDate);

        public async Task DeleteProcurementItemAsync(int procurementItemId, string? reason, Guid userId)
        {
            if (procurementItemId <= 0) throw new ValidationException("Invalid procurement item id.");
            await _writer.DeleteProcurementItemAsync(procurementItemId, reason?.Trim(), userId);
        }

        public async Task UpdateProcurementItemAsync(int procurementItemId, UpdateProcurementItemRequest request)
        {
            if (procurementItemId <= 0) throw new ValidationException("Invalid procurement item id.");
            if (string.IsNullOrWhiteSpace(request.ProductName)) throw new ValidationException("Product name is required.");
            if (request.Quantity <= 0) throw new ValidationException("Quantity must be greater than zero.");
            if (request.UnitPrice <= 0) throw new ValidationException("Unit price must be greater than zero.");

            var sanitized = new UpdateProcurementItemRequest
            {
                ProductName  = request.ProductName.Trim(),
                BrandName    = (request.BrandName ?? string.Empty).Trim(),
                CategoryName = (request.CategoryName ?? string.Empty).Trim(),
                Quantity     = request.Quantity,
                UnitPrice    = Math.Round(request.UnitPrice, 2, MidpointRounding.AwayFromZero),
                BatchNote    = string.IsNullOrWhiteSpace(request.BatchNote) ? null : request.BatchNote.Trim(),
            };
            await _writer.UpdateProcurementItemAsync(procurementItemId, sanitized);
        }

        public async Task DeleteDispatchItemAsync(int shipmentItemId, string? reason, Guid userId)
        {
            if (shipmentItemId <= 0) throw new ValidationException("Invalid shipment item id.");
            await _writer.DeleteDispatchItemAsync(shipmentItemId, reason?.Trim(), userId);
        }

        public async Task UpdateDispatchItemAsync(int shipmentItemId, UpdateDispatchItemRequest request)
        {
            if (shipmentItemId <= 0) throw new ValidationException("Invalid shipment item id.");
            if (request.QuantityDispatched <= 0) throw new ValidationException("Quantity dispatched must be greater than zero.");
            await _writer.UpdateDispatchItemAsync(shipmentItemId, request);
        }

        public Task<List<DeletedItemLogModel>> GetDeletedItemsAsync(string? tableName) => _reader.GetDeletedItemsAsync(tableName);

        private static List<PreparedDiscount> PrepareDiscounts(SaveProcurementRequest request, List<PreparedProcurementItem> items)
        {
            var prepared = new List<PreparedDiscount>();

            foreach (var discount in request.Discounts ?? new List<SaveDiscountRequest>())
            {
                var scope = string.IsNullOrWhiteSpace(discount.DiscountScope) ? "basket" : discount.DiscountScope.Trim().ToLowerInvariant();
                var type = string.IsNullOrWhiteSpace(discount.DiscountType) ? "fixed_amount" : discount.DiscountType.Trim().ToLowerInvariant();
                var targetItems = MatchDiscountItems(request.ShopName, scope, discount, items);

                if (!targetItems.Any())
                    continue;

                var discountAmount = CalculateDiscountAmount(type, discount, targetItems);
                if (discountAmount <= 0)
                    continue;

                var allocations = AllocateDiscount(targetItems, discountAmount);
                foreach (var allocation in allocations)
                {
                    var item = items.First(x => x.LineNumber == allocation.LineNumber);
                    item.DiscountTotal = RoundMoney(item.DiscountTotal + allocation.Amount);
                }

                prepared.Add(new PreparedDiscount
                {
                    DiscountCode = $"DISC-{prepared.Count + 1:000}",
                    DiscountType = type,
                    DiscountScope = scope,
                    Description = discount.Description?.Trim(),
                    TargetProductName = discount.TargetProductName?.Trim(),
                    TargetBrandName = discount.TargetBrandName?.Trim(),
                    TargetShopName = discount.TargetShopName?.Trim(),
                    BuyQuantity = discount.BuyQuantity,
                    PayQuantity = discount.PayQuantity,
                    Percentage = discount.Percentage,
                    FixedAmount = discount.FixedAmount,
                    DiscountAmount = discountAmount,
                    Notes = discount.Notes?.Trim(),
                    Allocations = allocations,
                });
            }

            return prepared;
        }

        private static List<PreparedProcurementItem> MatchDiscountItems(string shopName, string scope, SaveDiscountRequest discount, List<PreparedProcurementItem> items)
        {
            return scope switch
            {
                "item" => items.Where(item =>
                    !string.IsNullOrWhiteSpace(discount.TargetProductName) &&
                    string.Equals(item.ProductName, discount.TargetProductName.Trim(), StringComparison.OrdinalIgnoreCase)).ToList(),
                "brand" => items.Where(item =>
                    !string.IsNullOrWhiteSpace(discount.TargetBrandName) &&
                    string.Equals(item.BrandName, discount.TargetBrandName.Trim(), StringComparison.OrdinalIgnoreCase)).ToList(),
                "shop" => string.IsNullOrWhiteSpace(discount.TargetShopName) ||
                          string.Equals(shopName.Trim(), discount.TargetShopName.Trim(), StringComparison.OrdinalIgnoreCase)
                    ? items.ToList()
                    : new List<PreparedProcurementItem>(),
                _ => items.ToList(),
            };
        }

        private static decimal CalculateDiscountAmount(string type, SaveDiscountRequest discount, List<PreparedProcurementItem> items)
        {
            var totalGross = items.Sum(item => item.GrossTotal);
            var totalQuantity = items.Sum(item => item.Quantity);
            if (totalGross <= 0 || totalQuantity <= 0)
                return 0;

            decimal amount = type switch
            {
                "percentage" => totalGross * ((discount.Percentage ?? 0) / 100m),
                "buy_x_pay_y" => CalculateBuyXPayY(items, discount.BuyQuantity, discount.PayQuantity),
                "buy_x_get_amount_off" => Math.Floor(totalQuantity / (decimal)Math.Max(discount.BuyQuantity ?? 0, 1)) * (discount.FixedAmount ?? 0),
                "third_item_half_price" => CalculateNthItemDiscount(items, discount.BuyQuantity ?? 3, 50m),
                _ => discount.FixedAmount ?? 0,
            };

            return RoundMoney(Math.Min(amount, totalGross));
        }

        private static decimal CalculateBuyXPayY(List<PreparedProcurementItem> items, int? buyQuantity, int? payQuantity)
        {
            var buy = Math.Max(buyQuantity ?? 0, 1);
            var pay = Math.Clamp(payQuantity ?? buy, 0, buy);
            if (pay >= buy)
                return 0;

            var totalQty = items.Sum(item => item.Quantity);
            var freeUnits = (int)Math.Floor(totalQty / (decimal)buy) * (buy - pay);
            var averageUnit = items.Sum(item => item.GrossTotal) / totalQty;
            return RoundMoney(freeUnits * averageUnit);
        }

        private static decimal CalculateNthItemDiscount(List<PreparedProcurementItem> items, int buyQuantity, decimal discountPercent)
        {
            var qty = items.Sum(item => item.Quantity);
            if (buyQuantity <= 0 || qty <= 0)
                return 0;

            var qualifyingUnits = (int)Math.Floor(qty / (decimal)buyQuantity);
            var averageUnit = items.Sum(item => item.GrossTotal) / qty;
            return RoundMoney(qualifyingUnits * averageUnit * (discountPercent / 100m));
        }

        private static List<PreparedDiscountAllocation> AllocateDiscount(List<PreparedProcurementItem> items, decimal discountAmount)
        {
            var allocations = new List<PreparedDiscountAllocation>();
            var totalGross = items.Sum(item => item.GrossTotal);
            decimal running = 0;

            for (var index = 0; index < items.Count; index++)
            {
                var item = items[index];
                decimal amount;
                if (index == items.Count - 1)
                {
                    amount = RoundMoney(discountAmount - running);
                }
                else
                {
                    amount = RoundMoney(discountAmount * (item.GrossTotal / totalGross));
                    running = RoundMoney(running + amount);
                }

                allocations.Add(new PreparedDiscountAllocation
                {
                    LineNumber = item.LineNumber,
                    Amount = amount,
                });
            }

            return allocations;
        }

        private static void RecalculateNetCosts(List<PreparedProcurementItem> items)
        {
            foreach (var item in items)
            {
                item.DiscountTotal = RoundMoney(Math.Min(item.DiscountTotal, item.GrossTotal));
                item.NetTotal = RoundMoney(item.GrossTotal - item.DiscountTotal);
                item.NetUnitCost = item.Quantity <= 0 ? 0 : RoundMoney(item.NetTotal / item.Quantity);
            }
        }

        private static decimal RoundMoney(decimal value) => Math.Round(value, 2, MidpointRounding.AwayFromZero);

        private static string NormalizeCode(string? value, string prefix, DateTime date)
        {
            if (!string.IsNullOrWhiteSpace(value))
                return value.Trim().ToUpperInvariant();

            var actualDate = date == default ? DateTime.UtcNow : date;
            return $"{prefix}-{actualDate:yyyyMMdd}-{Guid.NewGuid().ToString("N")[..6].ToUpperInvariant()}";
        }

        private static string? NormalizeFilter(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

        private class PreparedProcurementItem
        {
            public int LineNumber { get; set; }
            public int? ProductId { get; set; }
            public string ProductName { get; set; } = string.Empty;
            public string BrandName { get; set; } = string.Empty;
            public string CategoryName { get; set; } = string.Empty;
            public int Quantity { get; set; }
            public decimal UnitPrice { get; set; }
            public decimal GrossTotal { get; set; }
            public decimal DiscountTotal { get; set; }
            public decimal NetTotal { get; set; }
            public decimal NetUnitCost { get; set; }
            public string? BatchNote { get; set; }
        }

        private class PreparedDiscount
        {
            public string DiscountCode { get; set; } = string.Empty;
            public string DiscountType { get; set; } = string.Empty;
            public string DiscountScope { get; set; } = string.Empty;
            public string? Description { get; set; }
            public string? TargetProductName { get; set; }
            public string? TargetBrandName { get; set; }
            public string? TargetShopName { get; set; }
            public int? BuyQuantity { get; set; }
            public int? PayQuantity { get; set; }
            public decimal? Percentage { get; set; }
            public decimal? FixedAmount { get; set; }
            public decimal DiscountAmount { get; set; }
            public string? Notes { get; set; }
            public List<PreparedDiscountAllocation> Allocations { get; set; } = new();
        }

        private class PreparedDiscountAllocation
        {
            public int LineNumber { get; set; }
            public decimal Amount { get; set; }
        }
    }
}
