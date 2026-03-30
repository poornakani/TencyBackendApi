using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.AuditEntity;

namespace TenzyBackend.Data.Audit
{
    public class AuditReader : IAuditReader
    {
        private readonly DapperMethods _dapper;

        public AuditReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<List<AdminAuditLogEntity>> GetAdminAuditLogsAsync(
            int pageSize, int offset, Guid? adminUserId = null)
        {
            var p = new DynamicParameters();
            p.Add("@PageSize",    pageSize,    DbType.Int32);
            p.Add("@Offset",      offset,      DbType.Int32);
            p.Add("@AdminUserId", adminUserId, DbType.Guid);

            return await _dapper.GetAllAsync<AdminAuditLogEntity>(
                "spAdminAuditLog_GetPaged", p, CommandType.StoredProcedure);
        }
    }
}
