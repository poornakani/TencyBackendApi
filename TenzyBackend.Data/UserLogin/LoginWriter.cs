using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.Enums;
using TenzyBackend.Entity.UserEntity;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Data.UserLogin
{
    public class LoginWriter : ILoginWriter
    {
        private readonly DapperMethods _dapperPro;

        public LoginWriter(DapperMethods dapperMethods)
        {
            _dapperPro=dapperMethods;
        }
        
        

        public async Task<Guid> InsertUser(UsersEntity user, int userrole, string passwordHash, string refreshHashtoken)
        {
            try
            {
                // --- Insert User ---
                var p = new DynamicParameters();
                p.Add("@Email", user.Email, DbType.String);
                p.Add("@EmailVerified", user.EmailVerified, DbType.Boolean);
                p.Add("@DisplayName", user.DisplayName, DbType.String);
                p.Add("@Status", 1, DbType.Int32);
                p.Add("@CreatedAt", user.CreatedAt == default ? DateTime.UtcNow : user.CreatedAt, DbType.DateTime2);
                p.Add("@LastLoginAt", user.LastLoginAt == default ? DateTime.UtcNow : user.LastLoginAt, DbType.DateTime2);

            
                Guid newUserId = await _dapperPro.InsertAsync<Guid>(
                    "spUser_Insert",
                    p,
                    commandType: CommandType.StoredProcedure
                );

                if (newUserId == Guid.Empty)
                    throw new Exception("User insert failed: returned empty Guid.");

                // --- Assign Role ---
                var pr = new DynamicParameters();
                pr.Add("@UserId", newUserId, DbType.Guid);
                pr.Add("@RoleId", (int)userrole, DbType.Int32);
                pr.Add("@AssignedAt", DateTime.UtcNow, DbType.DateTime2);

            
                await _dapperPro.InsertAsync<Guid>("spUserRoles_Insert",pr,commandType: CommandType.StoredProcedure);

                // --- Assign Password ---
                var pw = new DynamicParameters();
                pw.Add("@UserId", newUserId, DbType.Guid);
                pw.Add("@PasswordHash", passwordHash, DbType.String);
                pw.Add("@PasswordUpdatedAt", DateTime.Now, DbType.DateTime2);
                pw.Add("@FailedAttempts", 0, DbType.Int32);
                pw.Add("@LockedUntil", null);


                await _dapperPro.InsertAsync<Guid>("spPasswordCredentials_Insert",pw,commandType: CommandType.StoredProcedure);

                // --- Assign Refreash Token  ---

                var rf = new DynamicParameters();
                rf.Add("@UserId", newUserId, DbType.Guid);
                rf.Add("@RefreshTokenHash", refreshHashtoken, DbType.String);
                rf.Add("@ExpiresAt", DateTime.UtcNow.AddDays(30), DbType.DateTime2);

                await _dapperPro.InsertAsync<Guid>("spRefreshSessions_Insert", rf,commandType: CommandType.StoredProcedure);

                return newUserId; 
            }
            catch (Exception ex)
            {
                throw new SystemException(ex.Message, ex);
            }
        }

        public async Task<UsersEntity> UserfindByEmail(string email)
        {
            try
            {
                const string sql = @"select us.Id,
                                           us.Email,
                                           us.EmailVerified,
                                           us.DisplayName,
                                           us.Status,
                                           us.CreatedAt,
                                           us.LastLoginAt,
                                           usr.RoleId AS UserRole from Users us
                                    INNER JOIN UserRoles usr ON us.Id = usr.UserId
                                    INNER JOIN PasswordCredentials pss ON pss.UserId=usr.UserId
                                    INNER JOIN RefreshSessions refresh ON refresh.UserId = pss.UserId
                                    WHERE us.Email=@Email and us.Status=1";

                var p = new DynamicParameters();
                p.Add("@Email", email, DbType.String);

                // Assuming _dapperPro has a QuerySingleOrDefaultAsync method:
                var user = await _dapperPro.GetAsync<UsersEntity>(
                    sql,
                    p,
                    commandType: CommandType.Text
                );

                return user; 
            }
            catch (Exception ex)
            {
                throw new SystemException(ex.Message, ex);
            }
        }

        public async Task<UsersEntity> UserfindByID(Guid userID)
        {
            try
            {
                const string sql = @"select us.Id,
                                        us.Email,
                                        us.EmailVerified,
                                        us.DisplayName,
                                        us.Status,
                                        us.CreatedAt,
                                        us.LastLoginAt,
                                        usr.RoleId AS UserRole from Users us
                                    INNER JOIN UserRoles usr ON us.Id = usr.UserId
                                    INNER JOIN PasswordCredentials pss ON pss.UserId=usr.UserId
                                    INNER JOIN RefreshSessions refresh ON refresh.UserId = pss.UserId
                                    WHERE us.Id=@UserID and us.Status=1";

                var p = new DynamicParameters();
                p.Add("@UserID", userID, DbType.Guid);

                // Assuming _dapperPro has a QuerySingleOrDefaultAsync method:
                var user = await _dapperPro.GetAsync<UsersEntity>(
                    sql,
                    p,
                    commandType: CommandType.Text
                );

                return user;
            }
            catch (Exception ex)
            {
                throw new SystemException(ex.Message, ex);
            }
        }
        
        public async Task<string> GetuserPassword(string email)
        {
            try
            {
                string sql = @"select PasswordCredentials.PasswordHash from PasswordCredentials 
                                INNER JOIN Users ON PasswordCredentials.userID= Users.Id
                                where Users.Email=@Email";

                var dynamic = new DynamicParameters();
                dynamic.Add("@Email", email, DbType.String);

                string password = await _dapperPro.GetAsync<string>(sql, dynamic, commandType: CommandType.Text);

                return password;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
        
        public async Task<bool> ValidatePasswordLocks(string email)
        {

            // returns false = currently locked
            const string sql = @"
                    SELECT pc.FailedAttempts, pc.LockedUntil
                    FROM PasswordCredentials pc
                    INNER JOIN Users u ON pc.UserId = u.Id
                    WHERE u.Email = @Email;";

            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("@Email", email?.Trim(), DbType.String);

                var row = await _dapperPro.GetAsync<PasswordLockRowEntity>(
                    sql, parameters, commandType: CommandType.Text);

                // For login, usually just allow check to pass and later fail "invalid login".
                if (row == null)
                    return true;

                var now = DateTime.UtcNow;

                if (row.LockedUntil.HasValue && row.LockedUntil.Value > now)
                    return false; // locked

                return true; // not locked
            }
            catch (Exception ex)
            {
                throw new Exception("Failed to validate password lock state.", ex);
            }
        }

        public async Task RegisterFailedLoginAttempt(string email)
        {
            const string sql = @"
                UPDATE PasswordCredentials
                SET FailedAttempts = FailedAttempts + 1,
                    LockedUntil = CASE 
                        WHEN (FailedAttempts + 1) >= 5 THEN @LockedUntil
                        ELSE LockedUntil
                    END
                WHERE UserId = (SELECT Id FROM Users WHERE Email = @Email);";

            var now = DateTime.UtcNow;

            var parameters = new DynamicParameters();
            parameters.Add("@Email", email?.Trim(), DbType.String);
            parameters.Add("@LockedUntil", now.AddMinutes(10), DbType.DateTime2);

            await _dapperPro.ExecuteAsync(sql, parameters, commandType: CommandType.Text);
        }

        public async Task<Guid> ResetFailedAttempts(string email)
        {
            const string getUserSql = @"SELECT Id FROM Users WHERE Email = @Email;";
            const string updateSql = @"
                UPDATE PasswordCredentials
                SET FailedAttempts = 0,
                    LockedUntil = NULL
                WHERE UserId = @UserId;";

            var parameters = new DynamicParameters();
            parameters.Add("@Email", email?.Trim(), DbType.String);

            // Step 1: Get UserId
            Guid userId = await _dapperPro.GetAsync<Guid>(
                getUserSql, parameters, commandType: CommandType.Text);

            // Step 2: Reset attempts
            var updateParams = new DynamicParameters();
            updateParams.Add("@UserId", userId, DbType.Guid);

            await _dapperPro.ExecuteAsync(updateSql, updateParams, commandType: CommandType.Text);

            return userId;
        }

        public async Task<int> GetUserRole(string Email)
        {
            try
            {
                const string sql = @"
                    select RoleId from UserRoles ur
                    INNER JOIN Users us ON ur.UserId=us.Id where us.Email=@email";

                var parameters = new DynamicParameters();
                parameters.Add("@Email", Email?.Trim(), DbType.String);

                var row = await _dapperPro.GetAsync<int>(
                    sql, parameters, commandType: CommandType.Text);

                return row;
            }
            catch (Exception ex) 
            {
                throw new Exception("Failed to validate GetUserRole.", ex);
            }
        }

        public async Task<RefreshTokenUpdateResultEntity> UpdateRefreshToken(string email,string newHash)
        {
            try
            {
                var now = DateTime.UtcNow;
                var newExpiry = now.AddDays(30);

                var dy = new DynamicParameters();
                // 1) get user id
                const string getUserSql = @"SELECT Id FROM Users WHERE Email = @Email;";
                dy.Add("@Email", email?.Trim(), DbType.String);
                var userId = await _dapperPro.GetAsync<Guid?>(
                    getUserSql,
                    dy,
                    commandType: CommandType.Text);

                if (userId == null)
                    return new RefreshTokenUpdateResultEntity { Success = false };


                var re = new DynamicParameters();
                // 2) get latest refresh session
                const string getSessionSql = @"
                                SELECT TOP 1 UserId, RefreshTokenHash, ExpiresAt
                                FROM RefreshSessions
                                WHERE UserId = @UserId
                                ORDER BY CreatedAt DESC;";
                re.Add("@UserId", userId, DbType.Guid);
                var session = await _dapperPro.GetAsync<RefreshSessionRow>(
                    getSessionSql,
                    re,
                    commandType: CommandType.Text);



                if (session == null)
                {

                    var rf = new DynamicParameters();
                    rf.Add("@UserId", userId, DbType.Guid);
                    rf.Add("@RefreshTokenHash", newHash, DbType.String);
                    rf.Add("@ExpiresAt", DateTime.UtcNow.AddDays(30), DbType.DateTime2);

                    await _dapperPro.InsertAsync<Guid>("spRefreshSessions_Insert", rf, commandType: CommandType.StoredProcedure);

                    return new RefreshTokenUpdateResultEntity
                    {
                        Success = true,
                        WasRotated = true,
                        RefreshToken = newHash,
                        ExpiresAtUtc = newExpiry
                    };
                }

                bool expired = session.ExpiresAt <= now;

                if (expired)
                {

                    var update = new DynamicParameters();
                    const string updateSql = @"
                                UPDATE RefreshSessions SET RefreshTokenHash = @Hash,
                                    CreatedAt = @CreatedAt,
                                    ExpiresAt = @ExpiresAt
                                WHERE Id = @Id;";


                    update.Add("@Hash", newHash, DbType.String);
                    update.Add("@CreatedAt", DateTime.Now, DbType.DateTime2);
                    update.Add("@ExpiresAt", DateTime.UtcNow.AddDays(30), DbType.DateTime2);

                    await _dapperPro.ExecuteAsync(updateSql, update, CommandType.Text);

                    return new RefreshTokenUpdateResultEntity
                    {
                        Success = true,
                        WasRotated = true,
                        RefreshToken = newHash,
                        ExpiresAtUtc = newExpiry
                    };
                }
                else
                {
                    var update2 = new DynamicParameters();
                    const string extendSql = @"
                                            UPDATE RefreshSessions SET CreatedAt = @CreatedAt,
                                                ExpiresAt = @ExpiresAt WHERE UserId = @userId;";
     
                    update2.Add("@CreatedAt", DateTime.Now, DbType.DateTime2);
                    update2.Add("@ExpiresAt", DateTime.UtcNow.AddDays(30), DbType.DateTime2);
                    update2.Add("@UserId", userId, DbType.Guid);

                    await _dapperPro.ExecuteAsync(extendSql, update2, CommandType.Text);

                    return new RefreshTokenUpdateResultEntity
                    {
                        Success = true,
                        WasRotated = false,
                        RefreshToken = null,          
                        ExpiresAtUtc = newExpiry
                    };
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Failed to update refresh token.", ex);
            }
        }

        public Task<string> ValidateRefreshToken(Guid userId, string refreshTokenHash)
        {
            try 
            {
                string sql = @"SELECT RefreshTokenHash FROM RefreshSessions 
                                WHERE UserId = @UserId AND RefreshTokenHash = @Hash AND ExpiresAt > @Now";

                var dynamic = new DynamicParameters();
                dynamic.Add("@UserId", userId, DbType.Guid);
                dynamic.Add("@Hash", refreshTokenHash, DbType.String);
                dynamic.Add("@Now", DateTime.Now, DbType.DateTime2);

                var result = _dapperPro.GetAsync<string>(sql, dynamic, commandType: CommandType.Text).Result;  

                return Task.FromResult(result);
            }
            catch (Exception ex)
            {
                throw new Exception("Failed to validate refresh token.", ex);
            }
           
        }

        public async Task<bool> UpdateToNewrefreshToken(Guid userId, string newHash)
        {
            try 
            {
               
                string sql = @"UPDATE RefreshSessions SET RefreshTokenHash = @Hash, CreatedAt = @CreatedAt, ExpiresAt = @ExpiresAt
                               WHERE UserId = @UserId";

                var dynamic = new DynamicParameters();
                dynamic.Add("@UserId", userId, DbType.Guid);
                dynamic.Add("@Hash", newHash, DbType.String);
                dynamic.Add("@CreatedAt", DateTime.Now, DbType.DateTime2);
                dynamic.Add("@ExpiresAt", DateTime.UtcNow.AddDays(30), DbType.DateTime2);

                var result = await _dapperPro.UpdateAsync<int>(sql, dynamic, commandType: CommandType.Text);
                return (result>0);
                
            }
            catch(Exception ex)
            {
                throw new Exception("Failed to update to new refresh token.", ex);
            }
        }

        // ── customers (admin) ────────────────────────────────────────────────

        public async Task<List<CustomerAdminModel>> GetAllCustomersAsync(
            int pageSize, int offset, string? search)
        {
            const string sql = @"
                SELECT
                    u.Id,
                    u.DisplayName,
                    u.Email,
                    u.EmailVerified,
                    u.Status,
                    u.CreatedAt,
                    u.LastLoginAt,
                    COUNT(o.Id)                    AS TotalOrders,
                    COALESCE(SUM(o.TotalLkr), 0)    AS TotalSpent,
                    MAX(o.CreatedAt)               AS LastOrderDate
                FROM Users u
                INNER JOIN UserRoles ur ON ur.UserId = u.Id AND ur.RoleId = 2
                LEFT  JOIN Orders  o ON o.UserId = u.Id
                WHERE (@Search IS NULL
                       OR u.DisplayName LIKE '%' + @Search + '%'
                       OR u.Email       LIKE '%' + @Search + '%')
                GROUP BY u.Id, u.DisplayName, u.Email, u.EmailVerified,
                         u.Status, u.CreatedAt, u.LastLoginAt
                ORDER BY u.CreatedAt DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

            var p = new DynamicParameters();
            p.Add("@Offset",   offset,   DbType.Int32);
            p.Add("@PageSize", pageSize, DbType.Int32);
            p.Add("@Search",   search,   DbType.String);

            return await _dapperPro.GetAllAsync<CustomerAdminModel>(sql, p, CommandType.Text);
        }

        public async Task<CustomerAdminModel?> GetCustomerByIdAsync(Guid userId)
        {
            const string sql = @"
                SELECT
                    u.Id,
                    u.DisplayName,
                    u.Email,
                    u.EmailVerified,
                    u.Status,
                    u.CreatedAt,
                    u.LastLoginAt,
                    COUNT(o.Id)                    AS TotalOrders,
                    COALESCE(SUM(o.TotalLkr), 0)    AS TotalSpent,
                    MAX(o.CreatedAt)               AS LastOrderDate
                FROM Users u
                INNER JOIN UserRoles ur ON ur.UserId = u.Id AND ur.RoleId = 2
                LEFT  JOIN Orders  o ON o.UserId = u.Id
                WHERE u.Id = @UserId
                GROUP BY u.Id, u.DisplayName, u.Email, u.EmailVerified,
                         u.Status, u.CreatedAt, u.LastLoginAt;";

            var p = new DynamicParameters();
            p.Add("@UserId", userId, DbType.Guid);

            return await _dapperPro.GetAsync<CustomerAdminModel>(sql, p, CommandType.Text);
        }

        // ── forgot password ───────────────────────────────────────────────────

        public async Task StoreForgotPasswordTokenAsync(
            Guid userId, string tokenHash, DateTime expiresAt)
        {
            var p = new DynamicParameters();
            p.Add("@UserId",    userId,    DbType.Guid);
            p.Add("@TokenHash", tokenHash, DbType.String);
            p.Add("@ExpiresAt", expiresAt, DbType.DateTime2);

            await _dapperPro.ExecuteAsync(
                "spPasswordResetToken_Insert", p, CommandType.StoredProcedure);
        }

        public async Task<Guid?> ValidateForgotPasswordTokenAsync(string tokenHash)
        {
            var p = new DynamicParameters();
            p.Add("@TokenHash", tokenHash,       DbType.String);
            p.Add("@Now",       DateTime.UtcNow, DbType.DateTime2);

            return await _dapperPro.GetAsync<Guid?>(
                "spPasswordResetToken_Validate", p, CommandType.StoredProcedure);
        }

        public async Task<bool> ResetPasswordAsync(string tokenHash, string newPasswordHash)
        {
            var p = new DynamicParameters();
            p.Add("@TokenHash",       tokenHash,       DbType.String);
            p.Add("@NewPasswordHash", newPasswordHash, DbType.String);
            p.Add("@Now",             DateTime.UtcNow, DbType.DateTime2);

            var rows = await _dapperPro.ExecuteAsync(
                "spUser_UpdatePassword", p, CommandType.StoredProcedure);
            return rows > 0;
        }

        private class RefreshSessionRow
        {
            public Guid Id { get; set; }
            public string RefreshTokenHash { get; set; }
            public DateTime ExpiresAt { get; set; }
        }
    }
}
