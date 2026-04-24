using System.Security.Claims;
using TenzyBackend.Data.Audit;

namespace TencyBackendApi.Middleware
{
    /// <summary>
    /// Automatically logs all admin API mutations (POST/PUT/PATCH/DELETE) to AdminAuditLog.
    /// Runs after auth — only logs requests with a valid admin JWT (role = 3).
    /// </summary>
    public class AdminAuditMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<AdminAuditMiddleware> _logger;

        // Segments that carry no entity meaning
        private static readonly HashSet<string> _skip = new(StringComparer.OrdinalIgnoreCase)
            { "api", "admin", "supply-chain" };

        // Map plural/hyphenated path segments to friendly singular names
        private static readonly Dictionary<string, string> _entityNames = new(StringComparer.OrdinalIgnoreCase)
        {
            ["procurements"]    = "Procurement",
            ["dispatches"]      = "Dispatch",
            ["arrivals"]        = "Arrival",
            ["pricing"]         = "Pricing",
            ["products"]        = "Product",
            ["orders"]          = "Order",
            ["reviews"]         = "Review",
            ["customers"]       = "Customer",
            ["stock"]           = "Stock",
            ["brands"]          = "Brand",
            ["categories"]      = "Category",
            ["concerns"]        = "Concern",
            ["productimage"]    = "ProductImage",
            ["productfaq"]      = "ProductFaq",
            ["paymentoptions"]  = "PaymentOption",
            ["items"]           = "Item",
            ["charges"]         = "Charges",
        };

        // Map last path segment to a readable verb (when it isn't a number)
        private static readonly Dictionary<string, string> _verbMap = new(StringComparer.OrdinalIgnoreCase)
        {
            ["activate"]   = "Activate",
            ["deactivate"] = "Deactivate",
            ["delete"]     = "Delete",
            ["update"]     = "Update",
            ["approve"]    = "Approve",
            ["complete"]   = "Complete",
            ["refreshtoken"] = "RefreshToken",
        };

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
                var method = context.Request.Method;
                bool isMutation = method == "POST" || method == "PUT" ||
                                  method == "PATCH" || method == "DELETE";

                if (!isMutation || context.User?.Identity?.IsAuthenticated != true)
                    return;

                var roleClaim = context.User.FindFirst(ClaimTypes.Role)?.Value
                             ?? context.User.FindFirst("role")?.Value;
                if (roleClaim != "3") return;

                var userIdStr = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                             ?? context.User.FindFirst("sub")?.Value;
                if (!Guid.TryParse(userIdStr, out var adminUserId)) return;

                var path   = context.Request.Path.Value ?? string.Empty;
                var ip     = context.Connection.RemoteIpAddress?.ToString();
                var ua     = context.Request.Headers["User-Agent"].FirstOrDefault();
                var status = context.Response.StatusCode;

                var (entityType, entityId, verb) = ParsePath(path, method);
                var action = $"{verb} {entityType}".Trim();

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
                _logger.LogError(ex, "AdminAuditMiddleware failed to log audit entry");
            }
        }

        private static (string entityType, string? entityId, string verb) ParsePath(string path, string method)
        {
            // e.g. /api/admin/supply-chain/procurements/5/activate
            var segs = path.Trim('/').Split('/')
                           .Where(s => !string.IsNullOrEmpty(s) && !_skip.Contains(s))
                           .ToArray();

            string entityType = "Unknown";
            string? entityId  = null;
            string verb       = MethodVerb(method);

            // Find first non-numeric segment → entity name
            for (int i = 0; i < segs.Length; i++)
            {
                var s = segs[i];
                if (IsId(s)) continue;

                if (_entityNames.TryGetValue(s, out var friendly))
                    entityType = friendly;
                else
                    entityType = Capitalize(s.Replace("-", " "));

                // Next segment: if numeric it's the entity ID
                if (i + 1 < segs.Length && IsId(segs[i + 1]))
                    entityId = segs[i + 1];

                // Last segment: if a known verb, override the HTTP-method verb
                var last = segs[^1];
                if (!IsId(last) && last != s && _verbMap.TryGetValue(last, out var mappedVerb))
                    verb = mappedVerb;

                break;
            }

            return (entityType, entityId, verb);
        }

        private static bool IsId(string s)
            => int.TryParse(s, out _) || Guid.TryParse(s, out _);

        private static string MethodVerb(string method) => method switch
        {
            "POST"   => "Create",
            "PUT"    => "Update",
            "PATCH"  => "Update",
            "DELETE" => "Delete",
            _        => method,
        };

        private static string Capitalize(string s)
            => string.IsNullOrEmpty(s) ? s : char.ToUpperInvariant(s[0]) + s[1..];
    }
}
