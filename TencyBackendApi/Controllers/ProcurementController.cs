using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.AuditService;
using TenzyBackend.Core.Services.ProcurementService;
using TenzyBackend.Models.ApiResponseModels;
using TenzyBackend.Models.ProcurementModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/procurement")]
    [ApiController]
    [Authorize(Roles = "3")]
    public class ProcurementController : ControllerBase
    {
        private readonly IProcurementService _procurementService;
        private readonly IAuditService       _audit;

        public ProcurementController(IProcurementService procurementService, IAuditService audit)
        {
            _procurementService = procurementService;
            _audit              = audit;
        }

        // GET /api/procurement
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var orders = await _procurementService.GetAllOrdersAsync();
            return Ok(new ApiResponseModel { result = true, response = orders });
        }

        // GET /api/procurement/{id}
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var order = await _procurementService.GetOrderByIdAsync(id);
            return Ok(new ApiResponseModel { result = true, response = order });
        }

        // POST /api/procurement
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateProcurementOrderRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var newId = await _procurementService.CreateOrderAsync(request, userId.Value);
                await _audit.LogAdminActionAsync(userId.Value, "Create Procurement Order",
                    "Procurement", newId.ToString(),
                    newValues: JsonSerializer.Serialize(request),
                    ipAddress: GetIp());
                return CreatedAtAction(nameof(GetById), new { id = newId },
                    new ApiResponseModel { result = true, message = "Procurement order created.", response = new { id = newId } });
            }
            catch (Exception ex)
            {
                await TryLogError(userId.Value, "Create Procurement Order FAILED", "Procurement", null, ex, request);
                throw;
            }
        }

        // POST /api/procurement/{id}/status
        [HttpPost("{id:int}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateProcurementStatusRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                // Snapshot before
                var before = await _procurementService.GetOrderByIdAsync(id);
                await _procurementService.UpdateStatusAsync(id, request.Status, userId.Value);
                await _audit.LogAdminActionAsync(userId.Value, "Update Procurement Status",
                    "Procurement", id.ToString(),
                    oldValues: JsonSerializer.Serialize(new { status = before?.Status }),
                    newValues: JsonSerializer.Serialize(new { status = request.Status }),
                    ipAddress: GetIp());
                return Ok(new ApiResponseModel { result = true, message = $"Status updated to '{request.Status}'." });
            }
            catch (Exception ex)
            {
                await TryLogError(userId.Value, "Update Procurement Status FAILED", "Procurement", id.ToString(), ex, request);
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
