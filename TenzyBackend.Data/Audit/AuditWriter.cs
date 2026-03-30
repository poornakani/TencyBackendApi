using Dapper;
using System;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;

namespace TenzyBackend.Data.Audit
{
    public class AuditWriter : IAuditWriter
    {
        private readonly DapperMethods _dapper;

        public AuditWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task LogAdminActionAsync(
            Guid adminUserId,
            string action,
            string? entityType = null,
            string? entityId = null,
            string? oldValues = null,
            string? newValues = null,
            string? ipAddress = null,
            string? userAgent = null)
        {
            var p = new DynamicParameters();
            p.Add("@AdminUserId", adminUserId, DbType.Guid);
            p.Add("@Action",     action,     DbType.String);
            p.Add("@EntityType", entityType, DbType.String);
            p.Add("@EntityId",   entityId,   DbType.String);
            p.Add("@OldValues",  oldValues,  DbType.String);
            p.Add("@NewValues",  newValues,  DbType.String);
            p.Add("@IpAddress",  ipAddress,  DbType.String);
            p.Add("@UserAgent",  userAgent,  DbType.String);

            await _dapper.InsertAsync<long>(
                "spAdminAuditLog_Insert", p, CommandType.StoredProcedure);
        }

        public async Task LogLoginAttemptAsync(
            string email,
            bool isSuccess,
            Guid? userId = null,
            string? failReason = null,
            string? ipAddress = null,
            string? userAgent = null)
        {
            var p = new DynamicParameters();
            p.Add("@UserId",    userId,    DbType.Guid);
            p.Add("@Email",     email,     DbType.String);
            p.Add("@IsSuccess", isSuccess, DbType.Boolean);
            p.Add("@FailReason",failReason,DbType.String);
            p.Add("@IpAddress", ipAddress, DbType.String);
            p.Add("@UserAgent", userAgent, DbType.String);

            await _dapper.InsertAsync<long>(
                "spUserLoginHistory_Insert", p, CommandType.StoredProcedure);
        }
    }
}
