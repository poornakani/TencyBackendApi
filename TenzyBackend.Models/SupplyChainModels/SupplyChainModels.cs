using System;
using System.Collections.Generic;

namespace TenzyBackend.Models.SupplyChainModels
{
    public class SupplyChainDashboardModel
    {
        public int ProcurementCount { get; set; }
        public decimal ProcurementNetTotal { get; set; }
        public int ActiveShipmentCount { get; set; }
        public decimal ShipmentChargeTotal { get; set; }
        public int AwaitingVerificationCount { get; set; }
        public int EligiblePricingCount { get; set; }
        public decimal PricingValueTotal { get; set; }
    }

    public class SupplyProcurementListItemModel
    {
        public int ProcurementId { get; set; }
        public string ProcurementReference { get; set; } = string.Empty;
        public string ShopName { get; set; } = string.Empty;
        public DateTime PurchaseDate { get; set; }
        public string InvoiceReference { get; set; } = string.Empty;
        public string? PaymentCardName { get; set; }
        public string? PaymentReference { get; set; }
        public string Status { get; set; } = string.Empty;
        public decimal TotalGrossAmount { get; set; }
        public decimal TotalDiscountAmount { get; set; }
        public decimal TotalNetAmount { get; set; }
        public int ItemCount { get; set; }
        public string? PurchaseNote { get; set; }
    }

    public class SupplyProcurementModel : SupplyProcurementListItemModel
    {
        public Guid EnteredByUserId { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public List<SupplyProcurementItemModel> Items { get; set; } = new();
        public List<SupplyDiscountModel> Discounts { get; set; } = new();
    }

    public class SupplyProcurementItemModel
    {
        public int ProcurementItemId { get; set; }
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

    public class SupplyDiscountModel
    {
        public int DiscountId { get; set; }
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
        public List<SupplyDiscountAllocationModel> Allocations { get; set; } = new();
    }

    public class SupplyDiscountAllocationModel
    {
        public int DiscountId { get; set; }
        public int ProcurementItemId { get; set; }
        public int LineNumber { get; set; }
        public decimal Amount { get; set; }
    }

    public class SaveProcurementRequest
    {
        public int? ProcurementId { get; set; }
        public string? ProcurementReference { get; set; }
        public string ShopName { get; set; } = string.Empty;
        public DateTime PurchaseDate { get; set; }
        public string InvoiceReference { get; set; } = string.Empty;
        public string? PaymentCardName { get; set; }
        public string? PaymentReference { get; set; }
        public string? PurchaseNote { get; set; }
        public List<SaveProcurementItemRequest> Items { get; set; } = new();
        public List<SaveDiscountRequest> Discounts { get; set; } = new();
    }

    public class SaveProcurementItemRequest
    {
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string BrandName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public string? BatchNote { get; set; }
    }

    public class SaveDiscountRequest
    {
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
        public string? Notes { get; set; }
    }

    public class SupplyDispatchListItemModel
    {
        public int ShipmentId { get; set; }
        public string DispatchReference { get; set; } = string.Empty;
        public DateTime DispatchDate { get; set; }
        public string CourierName { get; set; } = string.Empty;
        public string ParcelNumber { get; set; } = string.Empty;
        public string ShipmentStatus { get; set; } = string.Empty;
        public decimal TotalProductCost { get; set; }
        public decimal TotalShipmentCharges { get; set; }
        public decimal TotalLandedCost { get; set; }
        public int TotalQuantity { get; set; }
        public string? Notes { get; set; }
    }

    public class SupplyDispatchModel : SupplyDispatchListItemModel
    {
        public List<SupplyDispatchItemModel> Items { get; set; } = new();
        public List<SupplyShipmentChargeModel> Charges { get; set; } = new();
    }

    public class SupplyDispatchItemModel
    {
        public int ShipmentItemId { get; set; }
        public int ShipmentId { get; set; }
        public int ProcurementItemId { get; set; }
        public int ProcurementId { get; set; }
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string BrandName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int QuantityDispatched { get; set; }
        public decimal NetUnitCost { get; set; }
        public decimal NetAmount { get; set; }
    }

    public class SupplyShipmentChargeModel
    {
        public int ShipmentChargeId { get; set; }
        public int ShipmentId { get; set; }
        public string ChargeType { get; set; } = string.Empty;
        public string CurrencyCode { get; set; } = "GBP";
        public decimal Amount { get; set; }
        public DateTime ChargeDate { get; set; }
        public string? Notes { get; set; }
    }

    public class SaveDispatchRequest
    {
        public int? ShipmentId { get; set; }
        public string? DispatchReference { get; set; }
        public DateTime DispatchDate { get; set; }
        public string CourierName { get; set; } = string.Empty;
        public string ParcelNumber { get; set; } = string.Empty;
        public string ShipmentStatus { get; set; } = "pending";
        public string? Notes { get; set; }
        public List<SaveDispatchItemRequest> Items { get; set; } = new();
    }

    public class SaveDispatchItemRequest
    {
        public int ProcurementItemId { get; set; }
        public int QuantityDispatched { get; set; }
    }

    public class AddShipmentChargeRequest
    {
        public string ChargeType { get; set; } = string.Empty;
        public string CurrencyCode { get; set; } = "GBP";
        public decimal Amount { get; set; }
        public DateTime ChargeDate { get; set; }
        public string? Notes { get; set; }
    }

    public class SupplyArrivalListItemModel
    {
        public int ArrivalVerificationId { get; set; }
        public int ShipmentId { get; set; }
        public string DispatchReference { get; set; } = string.Empty;
        public DateTime VerificationDate { get; set; }
        public string VerificationStatus { get; set; } = string.Empty;
        public int TotalApprovedQuantity { get; set; }
        public int TotalDamagedQuantity { get; set; }
        public int TotalMissingQuantity { get; set; }
        public string? Notes { get; set; }
    }

    public class SupplyArrivalModel : SupplyArrivalListItemModel
    {
        public List<SupplyArrivalItemModel> Items { get; set; } = new();
    }

    public class SupplyArrivalItemModel
    {
        public int ArrivalItemId { get; set; }
        public int ShipmentItemId { get; set; }
        public int ProcurementItemId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string BrandName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int QuantityDispatched { get; set; }
        public int QuantityReceived { get; set; }
        public int ApprovedQuantity { get; set; }
        public int MissingQuantity { get; set; }
        public int ExtraQuantity { get; set; }
        public int DamagedQuantity { get; set; }
        public bool ApprovedForPricing { get; set; }
        public decimal NetUnitCost { get; set; }
        public decimal AllocatedShipmentCostPerUnit { get; set; }
        public decimal LandedUnitCost { get; set; }
        public string? Notes { get; set; }
    }

    public class SaveArrivalRequest
    {
        public int? ArrivalVerificationId { get; set; }
        public int ShipmentId { get; set; }
        public DateTime VerificationDate { get; set; }
        public string VerificationStatus { get; set; } = "received";
        public string? Notes { get; set; }
        public List<SaveArrivalItemRequest> Items { get; set; } = new();
    }

    public class SaveArrivalItemRequest
    {
        public int ShipmentItemId { get; set; }
        public int QuantityReceived { get; set; }
        public int ApprovedQuantity { get; set; }
        public int MissingQuantity { get; set; }
        public int ExtraQuantity { get; set; }
        public int DamagedQuantity { get; set; }
        public bool ApprovedForPricing { get; set; }
        public string? Notes { get; set; }
    }

    public class EligiblePricingItemModel
    {
        public int ArrivalItemId { get; set; }
        public int ShipmentId { get; set; }
        public string DispatchReference { get; set; } = string.Empty;
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string BrandName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int ApprovedQuantity { get; set; }
        public decimal LandedUnitCost { get; set; }
        public decimal LandedTotalCost { get; set; }
        public bool IsPriced { get; set; }
    }

    public class SupplyPricingModel
    {
        public int PricingId { get; set; }
        public int ArrivalItemId { get; set; }
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string BrandName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int ApprovedQuantity { get; set; }
        public decimal LandedUnitCost { get; set; }
        public decimal SellingPrice { get; set; }
        public decimal CustomerDiscountPercent { get; set; }
        public decimal CustomerDiscountAmount { get; set; }
        public decimal FinalSellingPrice { get; set; }
        public decimal MarkupPercent { get; set; }
        public decimal MarginPercent { get; set; }
        public string? PricingNotes { get; set; }
        public bool IsApproved { get; set; }
        public DateTime ApprovedAtUtc { get; set; }
    }

    public class SavePricingRequest
    {
        public int? PricingId { get; set; }
        public int ArrivalItemId { get; set; }
        public decimal SellingPrice { get; set; }
        public decimal CustomerDiscountPercent { get; set; }
        public decimal CustomerDiscountAmount { get; set; }
        public string? PricingNotes { get; set; }
        public bool IsApproved { get; set; } = true;
    }

    public class SupplyProcurementReportRowModel
    {
        public string ProcurementReference { get; set; } = string.Empty;
        public DateTime PurchaseDate { get; set; }
        public string ShopName { get; set; } = string.Empty;
        public string InvoiceReference { get; set; } = string.Empty;
        public string? PaymentCardName { get; set; }
        public string? PaymentReference { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string BrandName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal GrossTotal { get; set; }
        public decimal DiscountTotal { get; set; }
        public decimal NetTotal { get; set; }
        public decimal NetUnitCost { get; set; }
        public string? PurchaseNote { get; set; }
    }

    public class SupplyDispatchReportRowModel
    {
        public string DispatchReference { get; set; } = string.Empty;
        public DateTime DispatchDate { get; set; }
        public string CourierName { get; set; } = string.Empty;
        public string ParcelNumber { get; set; } = string.Empty;
        public string ShipmentStatus { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string BrandName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int QuantityDispatched { get; set; }
        public decimal ProductCost { get; set; }
        public decimal UkCourierCharge { get; set; }
        public decimal SriLankaCourierCharge { get; set; }
        public decimal TaxCharge { get; set; }
        public decimal AdditionalCharge { get; set; }
        public decimal TotalShipmentCharge { get; set; }
    }

    public class SupplyMonthlyDispatchSummaryModel
    {
        public string SummaryMonth { get; set; } = string.Empty;
        public int TotalShipments { get; set; }
        public int TotalProductsDispatched { get; set; }
        public decimal TotalProductCost { get; set; }
        public decimal TotalUkCourierCost { get; set; }
        public decimal TotalSriLankaCourierCost { get; set; }
        public decimal TotalTaxCharges { get; set; }
        public decimal TotalAdditionalCharges { get; set; }
        public decimal TotalShipmentCost { get; set; }
    }
}
