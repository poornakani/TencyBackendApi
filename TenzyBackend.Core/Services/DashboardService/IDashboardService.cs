using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.DashboardModels;

namespace TenzyBackend.Core.Services.DashboardService
{
    public interface IDashboardService
    {
        Task<DashboardStatsModel> GetStatsAsync();
        Task<List<MonthlyRevenueModel>> GetMonthlyRevenueAsync();
        Task<List<OrderStatusBreakdownModel>> GetOrderStatusBreakdownAsync();
        Task<List<CategorySalesModel>> GetCategorySalesAsync();
        Task<List<TopProductModel>> GetTopProductsAsync(int top);
        Task<List<RecentOrderModel>> GetRecentOrdersAsync(int top);
    }
}
