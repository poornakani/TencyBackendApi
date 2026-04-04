using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
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

        public DispatchController(IDispatchService dispatchService)
        {
            _dispatchService = dispatchService;
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

            var id = await _dispatchService.UpsertDispatchAsync(request, adminId.Value);
            return Ok(new ApiResponseModel { result = true, message = "Dispatch info saved.", response = new { id } });
        }

        // POST /api/dispatch/{orderId}/delivered — mark order delivered
        [HttpPost("{orderId:int}/delivered")]
        public async Task<IActionResult> MarkDelivered(int orderId)
        {
            await _dispatchService.MarkDeliveredAsync(orderId);
            return Ok(new ApiResponseModel { result = true, message = "Order marked as delivered." });
        }

        private Guid? GetAdminUserId()
        {
            var s = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(s, out var g) ? g : null;
        }
    }
}
