using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TenzyBackend.Core.Services.AuditService;
using TenzyBackend.Models.ApiResponseModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/admin")]
    [ApiController]
    [Authorize(Roles = "3")]
    public class AdminController : ControllerBase
    {
        private readonly IAuditService _auditService;

        public AdminController(IAuditService auditService)
        {
            _auditService = auditService;
        }

        /// <summary>
        /// GET /api/admin/audit-logs?page=1&pageSize=50
        /// Returns paginated admin action log. Admin-only.
        /// </summary>
        [HttpGet("audit-logs")]
        public async Task<IActionResult> GetAuditLogs(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50,
            [FromQuery] Guid? adminUserId = null)
        {
            if (page < 1) page = 1;
            if (pageSize is < 1 or > 200) pageSize = 50;

            var logs = await _auditService.GetAdminAuditLogsAsync(page, pageSize, adminUserId);
            return Ok(new ApiResponseModel { result = true, response = logs });
        }

        /// <summary>
        /// GET /api/admin/my-activity — shows the calling admin's own log
        /// </summary>
        [HttpGet("my-activity")]
        public async Task<IActionResult> GetMyActivity(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                         ?? User.FindFirst("sub")?.Value;

            if (!Guid.TryParse(userIdStr, out var adminId))
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var logs = await _auditService.GetAdminAuditLogsAsync(page, pageSize, adminId);
            return Ok(new ApiResponseModel { result = true, response = logs });
        }
    }
}
