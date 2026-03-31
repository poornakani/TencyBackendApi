using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Data.Reports;
using TenzyBackend.Models.ReportModels;

namespace TenzyBackend.Core.Services.ReportService
{
    public class ReportService : IReportService
    {
        private readonly IReportReader _reader;

        public ReportService(IReportReader reader)
        {
            _reader = reader;
        }

        public Task<List<ReportRevenueRow>> GetRevenueReportAsync(
            DateTime startDate, DateTime endDate, string groupBy)
            => _reader.GetRevenueReportAsync(startDate, endDate, groupBy);

        public Task<List<ReportCategorySalesRow>> GetCategorySalesReportAsync(
            DateTime startDate, DateTime endDate)
            => _reader.GetCategorySalesReportAsync(startDate, endDate);

        public Task<List<ReportTopCustomerRow>> GetTopCustomersAsync(
            int top, DateTime startDate, DateTime endDate)
            => _reader.GetTopCustomersAsync(top > 0 ? top : 20, startDate, endDate);

        public Task<List<ReportTopProductRow>> GetTopProductsReportAsync(
            int top, DateTime startDate, DateTime endDate)
            => _reader.GetTopProductsReportAsync(top > 0 ? top : 20, startDate, endDate);
    }
}
