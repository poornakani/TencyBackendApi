using System;
using System.Collections.Generic;

namespace TenzyBackend.Models.ProcurementModels
{
    public class ProcurementOrderModel
    {
        public int Id { get; set; }
        public string OrderReference { get; set; } = string.Empty;
        public string SupplierName { get; set; } = string.Empty;
        public DateTime OrderDate { get; set; }
        public decimal GbpToLkr { get; set; }
        public decimal CourierCharges { get; set; }
        public decimal CustomsDuty { get; set; }
        public decimal OtherCharges { get; set; }
        public string? Notes { get; set; }
        public string Status { get; set; } = "ordered";
        public Guid CreatedByUserId { get; set; }
        public Guid? ApprovedByUserId { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public DateTime CreatedAt { get; set; }

        // Computed totals (calculated in service layer, not stored)
        public decimal TotalGbp => Items.Sum(i => i.Quantity * i.UnitPriceGbp);
        public decimal TotalLkr => TotalGbp * GbpToLkr;
        public decimal LandedCost => TotalLkr + CourierCharges + CustomsDuty + OtherCharges;

        public List<ProcurementItemModel> Items { get; set; } = new();
    }

    public class CreateProcurementOrderRequest
    {
        public string OrderReference { get; set; } = string.Empty;
        public string SupplierName { get; set; } = string.Empty;
        public DateTime OrderDate { get; set; }
        public decimal GbpToLkr { get; set; }
        public decimal CourierCharges { get; set; }
        public decimal CustomsDuty { get; set; }
        public decimal OtherCharges { get; set; }
        public string? Notes { get; set; }
        public List<ProcurementItemRequest> Items { get; set; } = new();
    }

    public class ProcurementItemRequest
    {
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPriceGbp { get; set; }
    }

    public class UpdateProcurementStatusRequest
    {
        public string Status { get; set; } = string.Empty;
    }
}
