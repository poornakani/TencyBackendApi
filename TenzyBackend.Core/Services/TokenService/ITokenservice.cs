using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.Enums;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Core.Services.TokenService
{
    public interface ITokenservice
    {
        Task<RegistrationResultModel> UserRegistration(UsersModel usersModel);
        Task<RegistrationResultModel> UserLogin(string Email, string Password);
        Task<RegistrationResultModel> GetRefreshToken(Guid userId, string refreshToken);
        
    }
}
