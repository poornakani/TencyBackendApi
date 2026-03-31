using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.ReportService;
using TenzyBackend.Models.ApiResponseModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/admin/reports")]
    [ApiController]
    [Authorize(Roles = "1")]
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportsController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("revenue")]
        public async Task<IActionResult> GetRevenue(
            [FromQuery] string? startDate,
            [FromQuery] string? endDate,
            [FromQuery] string groupBy = "month")
        {
            var (start, end) = ParseDateRange(startDate, endDate);
            var data = await _reportService.GetRevenueReportAsync(start, end, groupBy);
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        [HttpGet("categories")]
        public async Task<IActionResult> GetCategories(
            [FromQuery] string? startDate,
            [FromQuery] string? endDate)
        {
            var (start, end) = ParseDateRange(startDate, endDate);
            var data = await _reportService.GetCategorySalesReportAsync(start, end);
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        [HttpGet("customers")]
        public async Task<IActionResult> GetTopCustomers(
            [FromQuery] int top = 20,
            [FromQuery] string? startDate = null,
            [FromQuery] string? endDate = null)
        {
            var (start, end) = ParseDateRange(startDate, endDate);
            var data = await _reportService.GetTopCustomersAsync(top, start, end);
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        [HttpGet("products")]
        public async Task<IActionResult> GetTopProducts(
            [FromQuery] int top = 20,
            [FromQuery] string? startDate = null,
            [FromQuery] string? endDate = null)
        {
            var (start, end) = ParseDateRange(startDate, endDate);
            var data = await _reportService.GetTopProductsReportAsync(top, start, end);
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        private static (DateTime start, DateTime end) ParseDateRange(string? startDate, string? endDate)
        {
            var end   = DateTime.TryParse(endDate,   out var e) ? e : DateTime.UtcNow;
            var start = DateTime.TryParse(startDate, out var s) ? s : end.AddDays(-30);
            return (start, end);
        }
    }
}
