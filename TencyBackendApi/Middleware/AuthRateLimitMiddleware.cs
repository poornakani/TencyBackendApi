using Microsoft.Extensions.Caching.Memory;

namespace TencyBackendApi.Middleware
{
    /// <summary>
    /// Limits authentication attempts to 5 per IP per minute.
    /// Applies only to POST /api/userlogin/login and /api/userlogin/register.
    /// </summary>
    public class AuthRateLimitMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IMemoryCache _cache;
        private readonly ILogger<AuthRateLimitMiddleware> _logger;

        private const int MaxAttempts = 5;
        private static readonly TimeSpan Window = TimeSpan.FromMinutes(1);

        public AuthRateLimitMiddleware(
            RequestDelegate next,
            IMemoryCache cache,
            ILogger<AuthRateLimitMiddleware> logger)
        {
            _next   = next;
            _cache  = cache;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var path   = context.Request.Path.Value ?? string.Empty;
            var method = context.Request.Method;

            bool isAuthEndpoint =
                method == "POST" &&
                (path.Contains("/api/userlogin/login", StringComparison.OrdinalIgnoreCase) ||
                 path.Contains("/api/userlogin/register", StringComparison.OrdinalIgnoreCase));

            if (!isAuthEndpoint)
            {
                await _next(context);
                return;
            }

            string ip  = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            string key = $"rate_limit:{ip}:{path}";

            var (count, until) = _cache.GetOrCreate(key, entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = Window;
                return (Count: 0, Until: DateTimeOffset.UtcNow.Add(Window));
            });

            count++;
            _cache.Set(key, (count, until), until);

            if (count > MaxAttempts)
            {
                _logger.LogWarning("Rate limit exceeded for IP {Ip} on {Path}", ip, path);
                context.Response.StatusCode  = StatusCodes.Status429TooManyRequests;
                context.Response.Headers["Retry-After"] = ((int)(until - DateTimeOffset.UtcNow).TotalSeconds).ToString();
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync(
                    "{\"result\":false,\"message\":\"Too many attempts. Please wait before trying again.\"}");
                return;
            }

            await _next(context);
        }
    }
}
