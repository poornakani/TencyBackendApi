using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.ReportModels;

namespace TenzyBackend.Data.Reports
{
    public class ReportReader : IReportReader
    {
        private readonly DapperMethods _dapper;

        public ReportReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<List<ReportRevenueRow>> GetRevenueReportAsync(
            DateTime startDate, DateTime endDate, string groupBy)
        {
            var validGroups = new[] { "day", "week", "month" };
            if (!Array.Exists(validGroups, g => g == groupBy)) groupBy = "month";

            var p = new DynamicParameters();
            p.Add("@StartDate", startDate, DbType.Date);
            p.Add("@EndDate",   endDate,   DbType.Date);
            p.Add("@GroupBy",   groupBy,   DbType.String);

            return await _dapper.GetAllAsync<ReportRevenueRow>(
                "spReport_Revenue", p, CommandType.StoredProcedure);
        }

        public async Task<List<ReportCategorySalesRow>> GetCategorySalesReportAsync(
            DateTime startDate, DateTime endDate)
        {
            var p = new DynamicParameters();
            p.Add("@StartDate", startDate, DbType.Date);
            p.Add("@EndDate",   endDate,   DbType.Date);

            return await _dapper.GetAllAsync<ReportCategorySalesRow>(
                "spReport_SalesByCategory", p, CommandType.StoredProcedure);
        }

        public async Task<List<ReportTopCustomerRow>> GetTopCustomersAsync(
            int top, DateTime startDate, DateTime endDate)
        {
            var p = new DynamicParameters();
            p.Add("@Top",       top,       DbType.Int32);
            p.Add("@StartDate", startDate, DbType.Date);
            p.Add("@EndDate",   endDate,   DbType.Date);

            return await _dapper.GetAllAsync<ReportTopCustomerRow>(
                "spReport_TopCustomers", p, CommandType.StoredProcedure);
        }

        public async Task<List<ReportTopProductRow>> GetTopProductsReportAsync(
            int top, DateTime startDate, DateTime endDate)
        {
            var p = new DynamicParameters();
            p.Add("@Top",       top,       DbType.Int32);
            p.Add("@StartDate", startDate, DbType.Date);
            p.Add("@EndDate",   endDate,   DbType.Date);

            return await _dapper.GetAllAsync<ReportTopProductRow>(
                "spReport_SalesByProduct", p, CommandType.StoredProcedure);
        }
    }
}
