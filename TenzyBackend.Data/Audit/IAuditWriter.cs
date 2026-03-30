using System;
using System.Threading.Tasks;

namespace TenzyBackend.Data.Audit
{
    public interface IAuditWriter
    {
        Task LogAdminActionAsync(
            Guid adminUserId,
            string action,
            string? entityType = null,
            string? entityId = null,
            string? oldValues = null,
            string? newValues = null,
            string? ipAddress = null,
            string? userAgent = null);

        Task LogLoginAttemptAsync(
            string email,
            bool isSuccess,
            Guid? userId = null,
            string? failReason = null,
            string? ipAddress = null,
            string? userAgent = null);
    }
}
