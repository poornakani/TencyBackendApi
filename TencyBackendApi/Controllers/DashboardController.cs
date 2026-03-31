using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.DashboardService;
using TenzyBackend.Models.ApiResponseModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/admin/dashboard")]
    [ApiController]
    [Authorize(Roles = "1")]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            var stats = await _dashboardService.GetStatsAsync();
            return Ok(new ApiResponseModel { result = true, response = stats });
        }

        [HttpGet("monthly")]
        public async Task<IActionResult> GetMonthly()
        {
            var data = await _dashboardService.GetMonthlyRevenueAsync();
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        [HttpGet("order-status")]
        public async Task<IActionResult> GetOrderStatus()
        {
            var data = await _dashboardService.GetOrderStatusBreakdownAsync();
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        [HttpGet("category-sales")]
        public async Task<IActionResult> GetCategorySales()
        {
            var data = await _dashboardService.GetCategorySalesAsync();
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        [HttpGet("top-products")]
        public async Task<IActionResult> GetTopProducts([FromQuery] int top = 10)
        {
            var data = await _dashboardService.GetTopProductsAsync(top);
            return Ok(new ApiResponseModel { result = true, response = data });
        }

        [HttpGet("recent-orders")]
        public async Task<IActionResult> GetRecentOrders([FromQuery] int top = 10)
        {
            var data = await _dashboardService.GetRecentOrdersAsync(top);
            return Ok(new ApiResponseModel { result = true, response = data });
        }
    }
}
