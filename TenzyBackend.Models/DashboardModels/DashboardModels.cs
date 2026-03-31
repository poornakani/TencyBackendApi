using System;
using System.Collections.Generic;

namespace TenzyBackend.Models.DashboardModels
{
    public class DashboardStatsModel
    {
        public decimal TotalRevenue { get; set; }
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public int ProcessingOrders { get; set; }
        public int DispatchedOrders { get; set; }
        public int DeliveredOrders { get; set; }
        public int TotalCustomers { get; set; }
        public int TotalProducts { get; set; }
        public int LowStockProducts { get; set; }
        public int OutOfStockProducts { get; set; }
        public decimal RevenueThisMonth { get; set; }
        public decimal RevenueLastMonth { get; set; }
        public int OrdersThisMonth { get; set; }
        public int OrdersLastMonth { get; set; }
    }

    public class MonthlyRevenueModel
    {
        public string Month { get; set; } = string.Empty;
        public decimal Revenue { get; set; }
        public int Orders { get; set; }
        public int NewCustomers { get; set; }
    }

    public class OrderStatusBreakdownModel
    {
        public string Status { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class CategorySalesModel
    {
        public string Category { get; set; } = string.Empty;
        public int Units { get; set; }
        public decimal Revenue { get; set; }
    }

    public class TopProductModel
    {
        public int ProductId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int UnitsSold { get; set; }
        public decimal Revenue { get; set; }
        public int Stock { get; set; }
    }

    public class RecentOrderModel
    {
        public int Id { get; set; }
        public string OrderRef { get; set; } = string.Empty;
        public string CustomerName { get; set; } = string.Empty;
        public decimal TotalLkr { get; set; }
        public string Status { get; set; } = string.Empty;
        public string PaymentStatus { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }
}
