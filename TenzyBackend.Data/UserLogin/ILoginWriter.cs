using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.Enums;
using TenzyBackend.Entity.UserEntity;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Data.UserLogin
{
    public interface ILoginWriter
    {
        //create
        Task<Guid> InsertUser(UsersEntity user, int userrole, string passwordHash, string refreshHashtoken);

        //read
        Task<UsersEntity> UserfindByEmail(string email);
        Task<UsersEntity> UserfindByID(Guid userID);
        Task<string> GetuserPassword(string email);
        Task<int> GetUserRole(string email);
        Task<string> ValidateRefreshToken(Guid userId, string refreshTokenHash);

        //update
        Task<bool> ValidatePasswordLocks(string email);
        Task RegisterFailedLoginAttempt(string email);
        Task<Guid> ResetFailedAttempts(string email);
        Task<RefreshTokenUpdateResultEntity> UpdateRefreshToken(string email, string newHash);
        Task<bool> UpdateToNewrefreshToken(Guid userId, string newHash);

        // customers (admin)
        Task<List<CustomerAdminModel>> GetAllCustomersAsync(int pageSize, int offset, string? search);
        Task<CustomerAdminModel?> GetCustomerByIdAsync(Guid userId);

        // forgot password
        Task StoreForgotPasswordTokenAsync(Guid userId, string tokenHash, DateTime expiresAt);
        Task<Guid?> ValidateForgotPasswordTokenAsync(string tokenHash);
        Task<bool> ResetPasswordAsync(string tokenHash, string newPasswordHash);
    }
}
