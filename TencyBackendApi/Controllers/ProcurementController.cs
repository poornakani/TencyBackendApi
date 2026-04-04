using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
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

        public ProcurementController(IProcurementService procurementService)
        {
            _procurementService = procurementService;
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

            var newId = await _procurementService.CreateOrderAsync(request, userId.Value);

            return CreatedAtAction(nameof(GetById), new { id = newId },
                new ApiResponseModel
                {
                    result  = true,
                    message = "Procurement order created.",
                    response = new { id = newId }
                });
        }

        // POST /api/procurement/{id}/status
        [HttpPost("{id:int}/status")]
        public async Task<IActionResult> UpdateStatus(
            int id,
            [FromBody] UpdateProcurementStatusRequest request)
        {
            var userId = GetAdminUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            await _procurementService.UpdateStatusAsync(id, request.Status, userId.Value);

            return Ok(new ApiResponseModel
            {
                result  = true,
                message = $"Status updated to '{request.Status}'."
            });
        }

        private Guid? GetAdminUserId()
        {
            var s = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(s, out var g) ? g : null;
        }
    }
}
