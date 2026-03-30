using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Audit;
using TenzyBackend.Entity.AuditEntity;
using TenzyBackend.Models.AuditModels;

namespace TenzyBackend.Core.Services.AuditService
{
    public class AuditService : IAuditService
    {
        private readonly IAuditWriter _auditWriter;
        private readonly IAuditReader _auditReader;
        private readonly IObjectMapper _mapper;

        public AuditService(IAuditWriter auditWriter, IAuditReader auditReader, IObjectMapper mapper)
        {
            _auditWriter = auditWriter;
            _auditReader = auditReader;
            _mapper = mapper;
        }

        public Task LogAdminActionAsync(
            Guid adminUserId, string action,
            string? entityType = null, string? entityId = null,
            string? oldValues = null, string? newValues = null,
            string? ipAddress = null, string? userAgent = null)
            => _auditWriter.LogAdminActionAsync(adminUserId, action, entityType, entityId,
                                                oldValues, newValues, ipAddress, userAgent);

        public Task LogLoginAttemptAsync(
            string email, bool isSuccess,
            Guid? userId = null, string? failReason = null,
            string? ipAddress = null, string? userAgent = null)
            => _auditWriter.LogLoginAttemptAsync(email, isSuccess, userId, failReason, ipAddress, userAgent);

        public async Task<List<AdminAuditLogModel>> GetAdminAuditLogsAsync(
            int page, int pageSize, Guid? adminUserId = null)
        {
            int offset = (page - 1) * pageSize;
            var entities = await _auditReader.GetAdminAuditLogsAsync(pageSize, offset, adminUserId);
            return _mapper.Map<List<AdminAuditLogEntity>, List<AdminAuditLogModel>>(entities);
        }
    }
}
