using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.AuditService;
using TenzyBackend.Core.Services.DispatchService;
using TenzyBackend.Models.ApiResponseModels;
using TenzyBackend.Models.DispatchModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/dispatch")]
    [ApiController]
    [Authorize(Roles = "3")]
    public class DispatchController : ControllerBase
    {
        private readonly IDispatchService _dispatchService;
        private readonly IAuditService    _audit;

        public DispatchController(IDispatchService dispatchService, IAuditService audit)
        {
            _dispatchService = dispatchService;
            _audit           = audit;
        }

        // GET /api/dispatch/pending — orders awaiting dispatch
        [HttpGet("pending")]
        public async Task<IActionResult> GetPending()
        {
            var pending = await _dispatchService.GetPendingDispatchAsync();
            return Ok(new ApiResponseModel { result = true, response = pending });
        }

        // POST /api/dispatch — add/update tracking info on an order
        [HttpPost]
        public async Task<IActionResult> Upsert([FromBody] UpsertDispatchRequest request)
        {
            var adminId = GetAdminUserId();
            if (adminId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var id = await _dispatchService.UpsertDispatchAsync(request, adminId.Value);
                await _audit.LogAdminActionAsync(adminId.Value, "Save Dispatch",
                    "Dispatch", id.ToString(),
                    newValues: JsonSerializer.Serialize(request),
                    ipAddress: GetIp());
                return Ok(new ApiResponseModel { result = true, message = "Dispatch info saved.", response = new { id } });
            }
            catch (Exception ex)
            {
                await TryLogError(adminId.Value, "Save Dispatch FAILED", "Dispatch", null, ex, request);
                throw;
            }
        }

        // POST /api/dispatch/{orderId}/delivered — mark order delivered
        [HttpPost("{orderId:int}/delivered")]
        public async Task<IActionResult> MarkDelivered(int orderId)
        {
            var adminId = GetAdminUserId();
            try
            {
                await _dispatchService.MarkDeliveredAsync(orderId);
                if (adminId.HasValue)
                    await _audit.LogAdminActionAsync(adminId.Value, "Mark Order Delivered",
                        "Order", orderId.ToString(), ipAddress: GetIp());
                return Ok(new ApiResponseModel { result = true, message = "Order marked as delivered." });
            }
            catch (Exception ex)
            {
                if (adminId.HasValue)
                    await TryLogError(adminId.Value, "Mark Order Delivered FAILED", "Order", orderId.ToString(), ex);
                throw;
            }
        }

        /* ── helpers ───────────────────────────────────────────────────────── */
        private Guid? GetAdminUserId()
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
