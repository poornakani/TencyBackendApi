using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.AuditService;
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
        private readonly IAuditService _audit;

        public OrdersController(IOrderService orderService, IAuditService audit)
        {
            _orderService = orderService;
            _audit        = audit;
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
            var adminId = GetCurrentUserId();
            try
            {
                // Snapshot before
                var before = await _orderService.GetOrderByIdAsync(id);
                await _orderService.UpdateOrderStatusAsync(id, request.Status);
                if (adminId.HasValue)
                    await _audit.LogAdminActionAsync(adminId.Value, "Update Order Status",
                        "Order", id.ToString(),
                        oldValues: JsonSerializer.Serialize(new { status = before?.Status }),
                        newValues: JsonSerializer.Serialize(new { status = request.Status }),
                        ipAddress: GetIp());
                return Ok(new ApiResponseModel { result = true, message = $"Order status updated to '{request.Status}'." });
            }
            catch (Exception ex)
            {
                if (adminId.HasValue)
                    await TryLogError(adminId.Value, "Update Order Status FAILED", "Order", id.ToString(), ex, request);
                throw;
            }
        }

        /* ── helpers ───────────────────────────────────────────────────────── */
        private Guid? GetCurrentUserId()
        {
            var s = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(s, out var g) ? g : null;
        }

        private string? GetIp() => HttpContext.Connection.RemoteIpAddress?.ToString();

        private async Task TryLogError(Guid adminId, string action, string entityType,
            string? entityId, Exception ex, object? requestObj = null)
        {
            try
            {
                await _audit.LogAdminActionAsync(adminId, action, entityType, entityId,
                    oldValues: $"{ex.GetType().Name}: {ex.Message}",
                    newValues: requestObj != null ? JsonSerializer.Serialize(requestObj) : null,
                    ipAddress: GetIp());
            }
            catch { /* audit must never throw */ }
        }
    }
}
