using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.AuditService;
using TenzyBackend.Core.Services.SupplyChainService;
using TenzyBackend.Models.ApiResponseModels;
using TenzyBackend.Models.SupplyChainModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/admin/supply-chain")]
    [ApiController]
    [Authorize(Roles = "3")]
    public class SupplyChainController : ControllerBase
    {
        private readonly ISupplyChainService _service;
        private readonly IAuditService       _audit;

        public SupplyChainController(ISupplyChainService service, IAuditService audit)
        {
            _service = service;
            _audit   = audit;
        }

        /* ── Reads (no audit needed) ─────────────────────────────────────── */

        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboard()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDashboardAsync() });

        [HttpGet("procurements")]
        public async Task<IActionResult> GetProcurements()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetProcurementsAsync() });

        [HttpGet("procurements/{procurementId:int}")]
        public async Task<IActionResult> GetProcurementById(int procurementId)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetProcurementByIdAsync(procurementId) });

        [HttpGet("dispatches")]
        public async Task<IActionResult> GetDispatches()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDispatchesAsync() });

        [HttpGet("dispatches/{shipmentId:int}")]
        public async Task<IActionResult> GetDispatchById(int shipmentId)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDispatchByIdAsync(shipmentId) });

        [HttpGet("arrivals")]
        public async Task<IActionResult> GetArrivals()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetArrivalsAsync() });

        [HttpGet("arrivals/{arrivalVerificationId:int}")]
        public async Task<IActionResult> GetArrivalById(int arrivalVerificationId)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetArrivalByIdAsync(arrivalVerificationId) });

        [HttpGet("pricing/eligible")]
        public async Task<IActionResult> GetEligiblePricing()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetEligiblePricingItemsAsync() });

        [HttpGet("pricing")]
        public async Task<IActionResult> GetPricing()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetPricingAsync() });

        [HttpGet("reports/procurement")]
        public async Task<IActionResult> GetProcurementReport(
            [FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate,
            [FromQuery] string? shop, [FromQuery] string? brand,
            [FromQuery] string? product, [FromQuery] string? category)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetProcurementReportAsync(startDate, endDate, shop, brand, product, category) });

        [HttpGet("reports/dispatch")]
        public async Task<IActionResult> GetDispatchReport(
            [FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate,
            [FromQuery] string? courier, [FromQuery] string? brand,
            [FromQuery] string? product, [FromQuery] string? category, [FromQuery] string? shipmentStatus)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDispatchReportAsync(startDate, endDate, courier, brand, product, category, shipmentStatus) });

        [HttpGet("reports/monthly-dispatch-summary")]
        public async Task<IActionResult> GetMonthlyDispatchSummary(
            [FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetMonthlyDispatchSummaryAsync(startDate, endDate) });

        [HttpGet("deleted-items")]
        public async Task<IActionResult> GetDeletedItems([FromQuery] string? tableName)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDeletedItemsAsync(tableName) });

        /* ── Mutations (full audit) ──────────────────────────────────────── */

        [HttpPost("procurements")]
        public async Task<IActionResult> SaveProcurement([FromBody] SaveProcurementRequest request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var id = await _service.SaveProcurementAsync(request, userId.Value);
                await Log(userId.Value, "Create UK Purchase", "Procurement", id.ToString(),
                    newValues: JsonSerializer.Serialize(request));
                return Ok(new ApiResponseModel { result = true, message = "Procurement saved.", response = new { id } });
            }
            catch (Exception ex) { await LogError(userId.Value, "Create UK Purchase FAILED", "Procurement", null, ex, request); throw; }
        }

        [HttpPost("dispatches")]
        public async Task<IActionResult> SaveDispatch([FromBody] SaveDispatchRequest request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var id = await _service.SaveDispatchAsync(request, userId.Value);
                await Log(userId.Value, "Create Dispatch", "Dispatch", id.ToString(),
                    newValues: JsonSerializer.Serialize(request));
                return Ok(new ApiResponseModel { result = true, message = "Dispatch saved.", response = new { id } });
            }
            catch (Exception ex) { await LogError(userId.Value, "Create Dispatch FAILED", "Dispatch", null, ex, request); throw; }
        }

        [HttpPost("dispatches/{shipmentId:int}/charges")]
        public async Task<IActionResult> AddShipmentCharge(int shipmentId, [FromBody] AddShipmentChargeRequest request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var id = await _service.AddShipmentChargeAsync(shipmentId, request, userId.Value);
                await Log(userId.Value, "Add Shipment Charge", "Dispatch", shipmentId.ToString(),
                    newValues: JsonSerializer.Serialize(request));
                return Ok(new ApiResponseModel { result = true, message = "Shipment charge saved.", response = new { id } });
            }
            catch (Exception ex) { await LogError(userId.Value, "Add Shipment Charge FAILED", "Dispatch", shipmentId.ToString(), ex, request); throw; }
        }

        [HttpPost("arrivals")]
        public async Task<IActionResult> SaveArrival([FromBody] SaveArrivalRequest request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var id = await _service.SaveArrivalAsync(request, userId.Value);
                await Log(userId.Value, "Create Arrival Verification", "Arrival", id.ToString(),
                    newValues: JsonSerializer.Serialize(request));
                return Ok(new ApiResponseModel { result = true, message = "Arrival verification saved.", response = new { id } });
            }
            catch (Exception ex) { await LogError(userId.Value, "Create Arrival Verification FAILED", "Arrival", null, ex, request); throw; }
        }

        [HttpPost("pricing")]
        public async Task<IActionResult> SavePricing([FromBody] SavePricingRequest request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var id = await _service.SavePricingAsync(request, userId.Value);
                await Log(userId.Value, "Create Pricing", "Pricing", id.ToString(),
                    newValues: JsonSerializer.Serialize(request));
                return Ok(new ApiResponseModel { result = true, message = "Pricing saved.", response = new { id } });
            }
            catch (Exception ex) { await LogError(userId.Value, "Create Pricing FAILED", "Pricing", null, ex, request); throw; }
        }

        [HttpPost("pricing/{pricingId:int}/activate")]
        public async Task<IActionResult> ActivatePricing(int pricingId, [FromBody] ActivatePricingRequest? request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                var id = await _service.ActivatePricingAsync(pricingId, request?.ForceActivate ?? false, userId.Value);
                await Log(userId.Value, "Activate Pricing", "Pricing", pricingId.ToString(),
                    newValues: JsonSerializer.Serialize(new { pricingId, forceActivate = request?.ForceActivate ?? false }));
                return Ok(new ApiResponseModel { result = true, message = "Pricing activated.", response = new { id } });
            }
            catch (Exception ex) { await LogError(userId.Value, "Activate Pricing FAILED", "Pricing", pricingId.ToString(), ex); throw; }
        }

        [HttpPost("procurements/items/{procurementItemId:int}/delete")]
        public async Task<IActionResult> DeleteProcurementItem(int procurementItemId, [FromBody] DeleteStockItemRequest request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                await _service.DeleteProcurementItemAsync(procurementItemId, request.DeletionReason, userId.Value);
                await Log(userId.Value, "Delete Procurement Item", "ProcurementItem", procurementItemId.ToString(),
                    newValues: JsonSerializer.Serialize(new { reason = request.DeletionReason }));
                return Ok(new ApiResponseModel { result = true, message = "Item deleted." });
            }
            catch (Exception ex) { await LogError(userId.Value, "Delete Procurement Item FAILED", "ProcurementItem", procurementItemId.ToString(), ex); throw; }
        }

        [HttpPost("procurements/items/{procurementItemId:int}/update")]
        public async Task<IActionResult> UpdateProcurementItem(int procurementItemId, [FromBody] UpdateProcurementItemRequest request)
        {
            var userId = RequireAdmin();
            try
            {
                await _service.UpdateProcurementItemAsync(procurementItemId, request);
                if (userId.HasValue)
                    await Log(userId.Value, "Update Procurement Item", "ProcurementItem", procurementItemId.ToString(),
                        newValues: JsonSerializer.Serialize(request));
                return Ok(new ApiResponseModel { result = true, message = "Item updated." });
            }
            catch (Exception ex)
            {
                if (userId.HasValue) await LogError(userId.Value, "Update Procurement Item FAILED", "ProcurementItem", procurementItemId.ToString(), ex, request);
                throw;
            }
        }

        [HttpPost("dispatches/items/{shipmentItemId:int}/delete")]
        public async Task<IActionResult> DeleteDispatchItem(int shipmentItemId, [FromBody] DeleteStockItemRequest request)
        {
            var userId = RequireAdmin();
            if (userId == null) return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });
            try
            {
                await _service.DeleteDispatchItemAsync(shipmentItemId, request.DeletionReason, userId.Value);
                await Log(userId.Value, "Delete Dispatch Item", "DispatchItem", shipmentItemId.ToString(),
                    newValues: JsonSerializer.Serialize(new { reason = request.DeletionReason }));
                return Ok(new ApiResponseModel { result = true, message = "Item deleted." });
            }
            catch (Exception ex) { await LogError(userId.Value, "Delete Dispatch Item FAILED", "DispatchItem", shipmentItemId.ToString(), ex); throw; }
        }

        [HttpPost("dispatches/items/{shipmentItemId:int}/update")]
        public async Task<IActionResult> UpdateDispatchItem(int shipmentItemId, [FromBody] UpdateDispatchItemRequest request)
        {
            var userId = RequireAdmin();
            try
            {
                await _service.UpdateDispatchItemAsync(shipmentItemId, request);
                if (userId.HasValue)
                    await Log(userId.Value, "Update Dispatch Item", "DispatchItem", shipmentItemId.ToString(),
                        newValues: JsonSerializer.Serialize(request));
                return Ok(new ApiResponseModel { result = true, message = "Item updated." });
            }
            catch (Exception ex)
            {
                if (userId.HasValue) await LogError(userId.Value, "Update Dispatch Item FAILED", "DispatchItem", shipmentItemId.ToString(), ex, request);
                throw;
            }
        }

        /* ── helpers ─────────────────────────────────────────────────────── */

        private Guid? RequireAdmin()
        {
            var raw = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(raw, out var userId) ? userId : null;
        }

        private string? GetIp() => HttpContext.Connection.RemoteIpAddress?.ToString();

        private Task Log(Guid adminId, string action, string entityType, string? entityId = null,
            string? oldValues = null, string? newValues = null)
            => _audit.LogAdminActionAsync(adminId, action, entityType, entityId,
                oldValues, newValues, ipAddress: GetIp());

        private async Task LogError(Guid adminId, string action, string entityType,
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
