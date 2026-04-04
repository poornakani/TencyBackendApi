using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.OrderService;
using TenzyBackend.Models.ApiResponseModels;
using TenzyBackend.Models.OrderModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/orders")]
    [ApiController]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderService _orderService;

        public OrdersController(IOrderService orderService)
        {
            _orderService = orderService;
        }

        // GET /api/orders  — admin, filterable by ?status=pending&page=1&pageSize=20
        [HttpGet]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] string? status = null)
        {
            var orders = await _orderService.GetAllOrdersAsync(page, pageSize, status, null);
            return Ok(new ApiResponseModel { result = true, response = orders });
        }

        // GET /api/orders/{id}  — admin
        [HttpGet("{id:int}")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> GetById(int id)
        {
            var order = await _orderService.GetOrderByIdAsync(id);
            return Ok(new ApiResponseModel { result = true, response = order });
        }

        // GET /api/orders/my  — logged-in user sees their own orders
        [HttpGet("my")]
        [Authorize]
        public async Task<IActionResult> GetMyOrders(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var orders = await _orderService.GetUserOrdersAsync(userId.Value, page, pageSize);
            return Ok(new ApiResponseModel { result = true, response = orders });
        }

        // POST /api/orders  — logged-in user places order
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Create([FromBody] CreateOrderRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            // Always set UserId from JWT — never trust client-supplied value
            request.UserId = userId.Value;

            var newId = await _orderService.CreateOrderAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = newId },
                new ApiResponseModel { result = true, message = "Order placed successfully.", response = new { id = newId } });
        }

        // POST /api/orders/{id}/status  — admin
        [HttpPost("{id:int}/status")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateOrderStatusRequest request)
        {
            await _orderService.UpdateOrderStatusAsync(id, request.Status);
            return Ok(new ApiResponseModel { result = true, message = $"Order status updated to '{request.Status}'." });
        }

        private Guid? GetCurrentUserId()
        {
            var s = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(s, out var g) ? g : null;
        }
    }
}
