using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Data.Dashboard;
using TenzyBackend.Models.DashboardModels;

namespace TenzyBackend.Core.Services.DashboardService
{
    public class DashboardService : IDashboardService
    {
        private readonly IDashboardReader _reader;

        public DashboardService(IDashboardReader reader)
        {
            _reader = reader;
        }

        public Task<DashboardStatsModel> GetStatsAsync() => _reader.GetStatsAsync();
        public Task<List<MonthlyRevenueModel>> GetMonthlyRevenueAsync() => _reader.GetMonthlyRevenueAsync();
        public Task<List<OrderStatusBreakdownModel>> GetOrderStatusBreakdownAsync() => _reader.GetOrderStatusBreakdownAsync();
        public Task<List<CategorySalesModel>> GetCategorySalesAsync() => _reader.GetCategorySalesAsync();
        public Task<List<TopProductModel>> GetTopProductsAsync(int top) => _reader.GetTopProductsAsync(top > 0 ? top : 10);
        public Task<List<RecentOrderModel>> GetRecentOrdersAsync(int top) => _reader.GetRecentOrdersAsync(top > 0 ? top : 10);
    }
}
