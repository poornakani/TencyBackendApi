using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.AuditModels;

namespace TenzyBackend.Core.Services.AuditService
{
    public interface IAuditService
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

        Task<List<AdminAuditLogModel>> GetAdminAuditLogsAsync(int page, int pageSize, Guid? adminUserId = null);
    }
}
