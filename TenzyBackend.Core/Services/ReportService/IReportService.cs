using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.ReportModels;

namespace TenzyBackend.Core.Services.ReportService
{
    public interface IReportService
    {
        Task<List<ReportRevenueRow>> GetRevenueReportAsync(DateTime startDate, DateTime endDate, string groupBy);
        Task<List<ReportCategorySalesRow>> GetCategorySalesReportAsync(DateTime startDate, DateTime endDate);
        Task<List<ReportTopCustomerRow>> GetTopCustomersAsync(int top, DateTime startDate, DateTime endDate);
        Task<List<ReportTopProductRow>> GetTopProductsReportAsync(int top, DateTime startDate, DateTime endDate);
    }
}
