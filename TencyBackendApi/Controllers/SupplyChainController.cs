using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
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

        public SupplyChainController(ISupplyChainService service)
        {
            _service = service;
        }

        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboard()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDashboardAsync() });

        [HttpGet("procurements")]
        public async Task<IActionResult> GetProcurements()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetProcurementsAsync() });

        [HttpGet("procurements/{procurementId:int}")]
        public async Task<IActionResult> GetProcurementById(int procurementId)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetProcurementByIdAsync(procurementId) });

        [HttpPost("procurements")]
        public async Task<IActionResult> SaveProcurement([FromBody] SaveProcurementRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var id = await _service.SaveProcurementAsync(request, userId.Value);
            return Ok(new ApiResponseModel { result = true, message = "Procurement saved.", response = new { id } });
        }

        [HttpGet("dispatches")]
        public async Task<IActionResult> GetDispatches()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDispatchesAsync() });

        [HttpGet("dispatches/{shipmentId:int}")]
        public async Task<IActionResult> GetDispatchById(int shipmentId)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDispatchByIdAsync(shipmentId) });

        [HttpPost("dispatches")]
        public async Task<IActionResult> SaveDispatch([FromBody] SaveDispatchRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var id = await _service.SaveDispatchAsync(request, userId.Value);
            return Ok(new ApiResponseModel { result = true, message = "Dispatch saved.", response = new { id } });
        }

        [HttpPost("dispatches/{shipmentId:int}/charges")]
        public async Task<IActionResult> AddShipmentCharge(int shipmentId, [FromBody] AddShipmentChargeRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var id = await _service.AddShipmentChargeAsync(shipmentId, request, userId.Value);
            return Ok(new ApiResponseModel { result = true, message = "Shipment charge saved.", response = new { id } });
        }

        [HttpGet("arrivals")]
        public async Task<IActionResult> GetArrivals()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetArrivalsAsync() });

        [HttpGet("arrivals/{arrivalVerificationId:int}")]
        public async Task<IActionResult> GetArrivalById(int arrivalVerificationId)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetArrivalByIdAsync(arrivalVerificationId) });

        [HttpPost("arrivals")]
        public async Task<IActionResult> SaveArrival([FromBody] SaveArrivalRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var id = await _service.SaveArrivalAsync(request, userId.Value);
            return Ok(new ApiResponseModel { result = true, message = "Arrival verification saved.", response = new { id } });
        }

        [HttpGet("pricing/eligible")]
        public async Task<IActionResult> GetEligiblePricing()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetEligiblePricingItemsAsync() });

        [HttpGet("pricing")]
        public async Task<IActionResult> GetPricing()
            => Ok(new ApiResponseModel { result = true, response = await _service.GetPricingAsync() });

        [HttpPost("pricing")]
        public async Task<IActionResult> SavePricing([FromBody] SavePricingRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var id = await _service.SavePricingAsync(request, userId.Value);
            return Ok(new ApiResponseModel { result = true, message = "Pricing saved.", response = new { id } });
        }

        [HttpGet("reports/procurement")]
        public async Task<IActionResult> GetProcurementReport([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate, [FromQuery] string? shop, [FromQuery] string? brand, [FromQuery] string? product, [FromQuery] string? category)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetProcurementReportAsync(startDate, endDate, shop, brand, product, category) });

        [HttpGet("reports/dispatch")]
        public async Task<IActionResult> GetDispatchReport([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate, [FromQuery] string? courier, [FromQuery] string? brand, [FromQuery] string? product, [FromQuery] string? category, [FromQuery] string? shipmentStatus)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetDispatchReportAsync(startDate, endDate, courier, brand, product, category, shipmentStatus) });

        [HttpGet("reports/monthly-dispatch-summary")]
        public async Task<IActionResult> GetMonthlyDispatchSummary([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
            => Ok(new ApiResponseModel { result = true, response = await _service.GetMonthlyDispatchSummaryAsync(startDate, endDate) });

        private Guid? GetAdminUserId()
        {
            var raw = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(raw, out var userId) ? userId : null;
        }
    }
}
