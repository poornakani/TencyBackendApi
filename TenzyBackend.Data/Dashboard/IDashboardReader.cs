using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.DashboardModels;

namespace TenzyBackend.Data.Dashboard
{
    public interface IDashboardReader
    {
        Task<DashboardStatsModel> GetStatsAsync();
        Task<List<MonthlyRevenueModel>> GetMonthlyRevenueAsync();
        Task<List<OrderStatusBreakdownModel>> GetOrderStatusBreakdownAsync();
        Task<List<CategorySalesModel>> GetCategorySalesAsync();
        Task<List<TopProductModel>> GetTopProductsAsync(int top);
        Task<List<RecentOrderModel>> GetRecentOrdersAsync(int top);
    }
}
