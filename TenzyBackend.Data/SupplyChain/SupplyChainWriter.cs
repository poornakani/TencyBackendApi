using Dapper;
using System;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.SupplyChainModels;

namespace TenzyBackend.Data.SupplyChain
{
    public class SupplyChainWriter : ISupplyChainWriter
    {
        private readonly DapperMethods _dapper;

        public SupplyChainWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<int> SaveProcurementAsync(SaveProcurementRequest request, string itemsJson, string discountsJson, string allocationsJson, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ProcurementId", request.ProcurementId, DbType.Int32);
            p.Add("@ProcurementReference", request.ProcurementReference, DbType.String);
            p.Add("@ShopName", request.ShopName, DbType.String);
            p.Add("@PurchaseDate", request.PurchaseDate, DbType.DateTime2);
            p.Add("@InvoiceReference", request.InvoiceReference, DbType.String);
            p.Add("@PaymentCardName", request.PaymentCardName, DbType.String);
            p.Add("@PaymentReference", request.PaymentReference, DbType.String);
            p.Add("@PurchaseNote", request.PurchaseNote, DbType.String);
            p.Add("@EnteredByUserId", userId, DbType.Guid);
            p.Add("@ItemsJson", itemsJson, DbType.String);
            p.Add("@DiscountsJson", discountsJson, DbType.String);
            p.Add("@AllocationsJson", allocationsJson, DbType.String);

            return await _dapper.InsertAsync<int>("spSupplyProcurement_Save", p, CommandType.StoredProcedure);
        }

        public async Task<int> SaveDispatchAsync(SaveDispatchRequest request, string itemsJson, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ShipmentId", request.ShipmentId, DbType.Int32);
            p.Add("@DispatchReference", request.DispatchReference, DbType.String);
            p.Add("@DispatchDate", request.DispatchDate, DbType.DateTime2);
            p.Add("@CourierName", request.CourierName, DbType.String);
            p.Add("@ParcelNumber", request.ParcelNumber, DbType.String);
            p.Add("@ShipmentStatus", request.ShipmentStatus, DbType.String);
            p.Add("@Notes", request.Notes, DbType.String);
            p.Add("@CreatedByUserId", userId, DbType.Guid);
            p.Add("@ItemsJson", itemsJson, DbType.String);

            return await _dapper.InsertAsync<int>("spSupplyDispatch_Save", p, CommandType.StoredProcedure);
        }

        public async Task<int> AddShipmentChargeAsync(int shipmentId, AddShipmentChargeRequest request, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ShipmentId", shipmentId, DbType.Int32);
            p.Add("@ChargeType", request.ChargeType, DbType.String);
            p.Add("@CurrencyCode", request.CurrencyCode, DbType.String);
            p.Add("@Amount", request.Amount, DbType.Decimal);
            p.Add("@ChargeDate", request.ChargeDate, DbType.DateTime2);
            p.Add("@Notes", request.Notes, DbType.String);
            p.Add("@EnteredByUserId", userId, DbType.Guid);

            return await _dapper.InsertAsync<int>("spSupplyDispatch_AddCharge", p, CommandType.StoredProcedure);
        }

        public async Task<int> SaveArrivalAsync(SaveArrivalRequest request, string itemsJson, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ArrivalVerificationId", request.ArrivalVerificationId, DbType.Int32);
            p.Add("@ShipmentId", request.ShipmentId, DbType.Int32);
            p.Add("@VerificationDate", request.VerificationDate, DbType.DateTime2);
            p.Add("@VerificationStatus", request.VerificationStatus, DbType.String);
            p.Add("@Notes", request.Notes, DbType.String);
            p.Add("@VerifiedByUserId", userId, DbType.Guid);
            p.Add("@ItemsJson", itemsJson, DbType.String);

            return await _dapper.InsertAsync<int>("spSupplyArrival_Save", p, CommandType.StoredProcedure);
        }

        public async Task<int> SavePricingAsync(SavePricingRequest request, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@PricingId", request.PricingId, DbType.Int32);
            p.Add("@ArrivalItemId", request.ArrivalItemId, DbType.Int32);
            p.Add("@SellingPrice", request.SellingPrice, DbType.Decimal);
            p.Add("@CustomerDiscountPercent", request.CustomerDiscountPercent, DbType.Decimal);
            p.Add("@CustomerDiscountAmount", request.CustomerDiscountAmount, DbType.Decimal);
            p.Add("@PricingNotes", request.PricingNotes, DbType.String);
            p.Add("@IsApproved", request.IsApproved, DbType.Boolean);
            p.Add("@ApplicationMode", request.ApplicationMode, DbType.String);
            p.Add("@ApprovedByUserId", userId, DbType.Guid);

            return await _dapper.InsertAsync<int>("spSupplyPricing_Save", p, CommandType.StoredProcedure);
        }

        public async Task<int> ActivatePricingAsync(int pricingId, bool forceActivate, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@PricingId", pricingId, DbType.Int32);
            p.Add("@ForceActivate", forceActivate, DbType.Boolean);
            p.Add("@ApprovedByUserId", userId, DbType.Guid);

            return await _dapper.InsertAsync<int>("spSupplyPricing_Activate", p, CommandType.StoredProcedure);
        }

        public async Task DeleteProcurementItemAsync(int procurementItemId, string? reason, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ProcurementItemId", procurementItemId, DbType.Int32);
            p.Add("@DeletionReason", reason, DbType.String);
            p.Add("@DeletedByUserId", userId, DbType.Guid);
            await _dapper.ExecuteAsync("spSupplyProcurementItem_SoftDelete", p, CommandType.StoredProcedure);
        }

        public async Task UpdateProcurementItemAsync(int procurementItemId, UpdateProcurementItemRequest request)
        {
            var p = new DynamicParameters();
            p.Add("@ProcurementItemId", procurementItemId, DbType.Int32);
            p.Add("@ProductName", request.ProductName, DbType.String);
            p.Add("@BrandName", request.BrandName, DbType.String);
            p.Add("@CategoryName", request.CategoryName, DbType.String);
            p.Add("@Quantity", request.Quantity, DbType.Int32);
            p.Add("@UnitPrice", request.UnitPrice, DbType.Decimal);
            p.Add("@BatchNote", request.BatchNote, DbType.String);
            await _dapper.ExecuteAsync("spSupplyProcurementItem_Update", p, CommandType.StoredProcedure);
        }

        public async Task DeleteDispatchItemAsync(int shipmentItemId, string? reason, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ShipmentItemId", shipmentItemId, DbType.Int32);
            p.Add("@DeletionReason", reason, DbType.String);
            p.Add("@DeletedByUserId", userId, DbType.Guid);
            await _dapper.ExecuteAsync("spSupplyDispatchItem_SoftDelete", p, CommandType.StoredProcedure);
        }

        public async Task UpdateDispatchItemAsync(int shipmentItemId, UpdateDispatchItemRequest request)
        {
            var p = new DynamicParameters();
            p.Add("@ShipmentItemId", shipmentItemId, DbType.Int32);
            p.Add("@QuantityDispatched", request.QuantityDispatched, DbType.Int32);
            await _dapper.ExecuteAsync("spSupplyDispatchItem_Update", p, CommandType.StoredProcedure);
        }
    }
}
