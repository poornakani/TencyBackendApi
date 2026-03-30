using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Entity.AuditEntity;

namespace TenzyBackend.Data.Audit
{
    public interface IAuditReader
    {
        Task<List<AdminAuditLogEntity>> GetAdminAuditLogsAsync(int pageSize, int offset, Guid? adminUserId = null);
    }
}
