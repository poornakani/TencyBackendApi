using System;
using System.Collections.Generic;

namespace TenzyBackend.Entity.ProcurementEntity
{
    public class ProcurementOrderEntity
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
        public DateTime? UpdatedAt { get; set; }

        public List<ProcurementItemEntity> Items { get; set; } = new();
    }
}
