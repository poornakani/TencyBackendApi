using System;
using System.Collections.Generic;

namespace TenzyBackend.Entity.OrderEntity
{
    public class OrderEntity
    {
        public int Id { get; set; }
        public string OrderRef { get; set; } = string.Empty;
        public Guid UserId { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public string CustomerEmail { get; set; } = string.Empty;
        public string Status { get; set; } = "pending";
        public string PaymentMethod { get; set; } = string.Empty;
        public string PaymentStatus { get; set; } = "pending";
        public string ShippingName { get; set; } = string.Empty;
        public string ShippingPhone { get; set; } = string.Empty;
        public string ShippingAddress { get; set; } = string.Empty;
        public string ShippingCity { get; set; } = string.Empty;
        public decimal SubtotalLkr { get; set; }
        public decimal ShippingFee { get; set; }
        public decimal DiscountLkr { get; set; }
        public decimal TotalLkr { get; set; }
        public string? Notes { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int ItemCount { get; set; }
        public List<OrderItemEntity> Items { get; set; } = new();
    }
}
