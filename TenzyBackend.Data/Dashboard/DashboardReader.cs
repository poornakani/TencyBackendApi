using Dapper;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.DashboardModels;

namespace TenzyBackend.Data.Dashboard
{
    public class DashboardReader : IDashboardReader
    {
        private readonly DapperMethods _dapper;

        public DashboardReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<DashboardStatsModel> GetStatsAsync()
        {
            return await _dapper.GetAsync<DashboardStatsModel>(
                "spDashboard_GetStats", null, CommandType.StoredProcedure)
                ?? new DashboardStatsModel();
        }

        public async Task<List<MonthlyRevenueModel>> GetMonthlyRevenueAsync()
        {
            return await _dapper.GetAllAsync<MonthlyRevenueModel>(
                "spDashboard_GetRevenueMonthly", commandType: CommandType.StoredProcedure);
        }

        public async Task<List<OrderStatusBreakdownModel>> GetOrderStatusBreakdownAsync()
        {
            return await _dapper.GetAllAsync<OrderStatusBreakdownModel>(
                "spDashboard_GetOrderStatusBreakdown", commandType: CommandType.StoredProcedure);
        }

        public async Task<List<CategorySalesModel>> GetCategorySalesAsync()
        {
            return await _dapper.GetAllAsync<CategorySalesModel>(
                "spDashboard_GetCategorySales", commandType: CommandType.StoredProcedure);
        }

        public async Task<List<TopProductModel>> GetTopProductsAsync(int top)
        {
            var p = new DynamicParameters();
            p.Add("@Top", top, DbType.Int32);
            return await _dapper.GetAllAsync<TopProductModel>(
                "spDashboard_GetTopProducts", p, CommandType.StoredProcedure);
        }

        public async Task<List<RecentOrderModel>> GetRecentOrdersAsync(int top)
        {
            var p = new DynamicParameters();
            p.Add("@Top", top, DbType.Int32);
            return await _dapper.GetAllAsync<RecentOrderModel>(
                "spDashboard_GetRecentOrders", p, CommandType.StoredProcedure);
        }
    }
}
