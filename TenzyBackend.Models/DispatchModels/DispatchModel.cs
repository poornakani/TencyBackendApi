using System;

namespace TenzyBackend.Models.DispatchModels
{
    public class DispatchModel
    {
        public int Id { get; set; }
        public int OrderId { get; set; }
        public string OrderRef { get; set; } = string.Empty;
        public string CustomerName { get; set; } = string.Empty;
        public string ShippingCity { get; set; } = string.Empty;
        public decimal TotalLkr { get; set; }
        public string OrderStatus { get; set; } = string.Empty;
        public string? TrackingId { get; set; }
        public string? Courier { get; set; }
        public DateTime? DispatchedAt { get; set; }
        public DateTime? EstimatedDelivery { get; set; }
        public DateTime? DeliveredAt { get; set; }
        public string? Notes { get; set; }
    }

    public class UpsertDispatchRequest
    {
        public int OrderId { get; set; }
        public string? TrackingId { get; set; }
        public string? Courier { get; set; }
        public DateTime? EstimatedDelivery { get; set; }
        public string? Notes { get; set; }
    }
}
