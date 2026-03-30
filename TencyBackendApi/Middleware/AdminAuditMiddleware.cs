using System.Security.Claims;
using TenzyBackend.Data.Audit;

namespace TencyBackendApi.Middleware
{
    /// <summary>
    /// Automatically logs all admin API mutations (POST/PUT/PATCH/DELETE) to AdminAuditLog.
    /// Runs after auth — only logs requests with a valid admin JWT (role = 1).
    /// </summary>
    public class AdminAuditMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<AdminAuditMiddleware> _logger;

        public AdminAuditMiddleware(RequestDelegate next, ILogger<AdminAuditMiddleware> logger)
        {
            _next   = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context, IAuditWriter auditWriter)
        {
            await _next(context);

            try
            {
                // Only audit mutating methods for authenticated admins
                var method = context.Request.Method;
                bool isMutation = method == "POST" || method == "PUT" ||
                                  method == "PATCH" || method == "DELETE";

                if (!isMutation || context.User?.Identity?.IsAuthenticated != true)
                    return;

                // Check role == 1 (admin)
                var roleClaim = context.User.FindFirst(ClaimTypes.Role)?.Value
                             ?? context.User.FindFirst("role")?.Value;
                if (roleClaim != "1") return;

                var userIdStr = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                             ?? context.User.FindFirst("sub")?.Value;
                if (!Guid.TryParse(userIdStr, out var adminUserId)) return;

                var path     = context.Request.Path.Value ?? string.Empty;
                var action   = $"{method} {path}";
                var ip       = context.Connection.RemoteIpAddress?.ToString();
                var ua       = context.Request.Headers["User-Agent"].FirstOrDefault();
                var status   = context.Response.StatusCode;

                // Derive entity type from path: /api/products/5 → "Product" + id "5"
                var segments   = path.Trim('/').Split('/');
                var entityType = segments.Length >= 2 ? Capitalize(segments[1]) : null;
                var entityId   = segments.Length >= 3 ? segments[2] : null;

                await auditWriter.LogAdminActionAsync(
                    adminUserId: adminUserId,
                    action:      $"{action} ({status})",
                    entityType:  entityType,
                    entityId:    entityId,
                    ipAddress:   ip,
                    userAgent:   ua
                );
            }
            catch (Exception ex)
            {
                // Audit failure must never break the main request
                _logger.LogError(ex, "AdminAuditMiddleware failed to log audit entry");
            }
        }

        private static string Capitalize(string s)
            => string.IsNullOrEmpty(s) ? s : char.ToUpperInvariant(s[0]) + s[1..];
    }
}
