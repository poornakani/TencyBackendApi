using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;
using System;

using System.IdentityModel.Tokens.Jwt;

using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

using TenzyBackend.Core.Functions;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.UserLogin;

using TenzyBackend.Entity.UserEntity;

using TenzyBackend.Models.UserModel;
using JwtRegisteredClaimNames = Microsoft.IdentityModel.JsonWebTokens.JwtRegisteredClaimNames;

namespace TenzyBackend.Core.Services.TokenService
{
    public class Tokenservice : ITokenservice
    {
        public IConfiguration Configuration { get; set; }
        public readonly ILoginWriter _loginWriter;
        private readonly IObjectMapper _objectMapper;
        public Tokenservice(IConfiguration configuration,ILoginWriter loginWriter, IObjectMapper objectMapper)
        {
            Configuration= configuration;
            _loginWriter= loginWriter;
            _objectMapper = objectMapper;
        }
        
        
        public async Task<RegistrationResultModel> UserRegistration(UsersModel usersModel)
        {
            
            // 1) Validate request
            
            if (usersModel is null)
                return new RegistrationResultModel {  Message = "Request is required." };
            if(usersModel.UserRole<=0)
                return new RegistrationResultModel { Message = "User role required" };
            if (string.IsNullOrWhiteSpace(usersModel.Email))
                return new RegistrationResultModel {  Message = "Email is required." };

            if (string.IsNullOrWhiteSpace(usersModel.Password))
                return new RegistrationResultModel
                {
                    Message = "Password is required.",
                    Errors = new List<string> { "Password is required." }
                };

            // Validate password rules with detailed errors (recommended)
            var pwdErrors = PasswordValidator.Validate(usersModel.Password);
            if (pwdErrors.Count > 0)
            {
                return new RegistrationResultModel
                {
                    Message = "Password validation failed.",
                    Errors = pwdErrors
                };
            }

            // Normalize email (important)
            var email = usersModel.Email.Trim().ToLowerInvariant();
            usersModel.Email = email;

            try
            {
                // 3) Email exists?
                var existing = await _loginWriter.UserfindByEmail(email);
                if (existing != null)
                {
                    // Avoid exposing userId (recommended)
                    return new RegistrationResultModel
                    {
                        Message = "Email already exists.",
                        Email = email
                    };
                }

                // 4) Hash password
                var hashPassword = PasswordHasher.Hash(usersModel.Password);

                // 5) Map
                var userEntity = _objectMapper.Map<UsersModel, UsersEntity>(usersModel);
                //var roleEntity = _objectMapper.Map<UserRoleEnumsModel, UserRoleEnumsEntity>(userRoleEnumsmodel);

                // 6) Create refresh token (raw token to return)
                var rawRefreshToken = GenerateRefreshToken();
                var refreshTokenHash = HashRefreshToken(rawRefreshToken);

                // 8)
                var userID = await _loginWriter.InsertUser(userEntity, userEntity.UserRole, hashPassword, refreshTokenHash);


                // 9) Generate access token AFTER commit
                var (accessToken, expiresAt) = GenerateAccessToken(userID, email, userEntity.UserRole);

                return new RegistrationResultModel
                {
                    Message = "User registered successfully.",
                    Email = email,
                    Username = usersModel.DisplayName,
                    UserId = userID,
                    RoleId = userEntity.UserRole,
                    AccessToken = accessToken,
                    RefreshToken= refreshTokenHash,
                    AccessTokenExpiresAt = expiresAt,
                };
            }
            catch (Exception ex)
            {
                // Log ex here (don’t throw SystemException)
                return new RegistrationResultModel
                {
                    Message = "Registration failed. Please try again."
                };
            }
           
        }

        public async Task<RegistrationResultModel> UserLogin(string Email, string Password)
        {
            try
            {
                if(string.IsNullOrEmpty(Email) || string.IsNullOrEmpty(Password))
                    return new RegistrationResultModel { Message = "Please check the Email and the Password" };

                //validate the email address

                var existing = await _loginWriter.UserfindByEmail(Email);
                if (existing == null)
                    return new RegistrationResultModel { Message = "Invalid email or password" };

                // get the password from the user for validation
                string hashedPassword = await _loginWriter.GetuserPassword(Email);
                if (string.IsNullOrEmpty(hashedPassword))
                    return new RegistrationResultModel { Message = "System issue no password found in DB" };


                //validate the password locks
                bool allowed = await _loginWriter.ValidatePasswordLocks(Email);
                if (!allowed)
                    return new RegistrationResultModel { Message = "Account locked. Try again later." };


                // validate the password
                bool passwordValidate = PasswordHasher.Verify(Password,hashedPassword);

                if (!passwordValidate)
                {
                    await _loginWriter.RegisterFailedLoginAttempt(Email);
                    return new RegistrationResultModel
                    {
                        Message = "Password is incorrect, please use the correct password or " +
                        "reset the password"
                    };
                }
                Guid userID =await _loginWriter.ResetFailedAttempts(Email);

                // get the user role
                int roleEntity = await _loginWriter.GetUserRole(Email);
                if(roleEntity<=0)
                    return new RegistrationResultModel
                    {
                        Message = "Invalide User role for this user"
                    };


                //genarate access token 
                var (accessToken, expiresAt) = GenerateAccessToken(userID, Email, roleEntity);
                var rawRefreshToken = GenerateRefreshToken();
                var refreshTokenHash = HashRefreshToken(rawRefreshToken);

                //update the and fix the refresh token
                var result = await _loginWriter.UpdateRefreshToken(Email, refreshTokenHash);

                return new RegistrationResultModel
                {
                    Message = "User Log in success",
                    Email = Email,
                    Username = existing.DisplayName,
                    UserId = userID,
                    RoleId= roleEntity,
                    AccessToken = accessToken,
                    RefreshToken= rawRefreshToken,
                    AccessTokenExpiresAt = expiresAt,
                };
            }
            catch (Exception ex) 
            {
                return new RegistrationResultModel
                {
                    Message = "Registration failed. Please try again."
                };
            }
        }

        public async Task<RegistrationResultModel> GetRefreshToken(Guid userId, string refreshToken)
        {
            try
            {
                // Validate inputs
                if (userId == Guid.Empty)
                    return new RegistrationResultModel { Message = "Invalid user id." };

                if (string.IsNullOrWhiteSpace(refreshToken))
                    return new RegistrationResultModel { Message = "Refresh token is required." };

                // Check the user exists
                var userdetails = await _loginWriter.UserfindByID(userId);
                 if (userdetails == null)
                    return new RegistrationResultModel { Message = "Unauthorized user, Please try to relogin" };

                // Convert raw token to hash and validate with DB
                var refreshTokenHash = HashRefreshToken(refreshToken);
                var validation = await _loginWriter.ValidateRefreshToken(userId, refreshTokenHash);

                // If validation failed -> rotate refresh token and return new tokens
                if (validation == null)
                {
                    var (accessToken, expiresAt) = GenerateAccessToken(userId, userdetails.Email, userdetails.UserRole);
                    var rawRefreshToken = GenerateRefreshToken();
                    var newRefreshTokenHash = HashRefreshToken(rawRefreshToken);

                    var result = await _loginWriter.UpdateToNewrefreshToken(userId, newRefreshTokenHash);

                    return new RegistrationResultModel
                    {
                        Message = "Refresh token rotated.",
                        Email = userdetails.Email,
                        UserId = userId,
                        AccessToken = accessToken,
                        RefreshToken = rawRefreshToken,
                        AccessTokenExpiresAt = expiresAt
                    };
                }

                // Validation succeeded -> issue new access token and extend refresh token lifetime
                var (newAccessToken, newExpiresAt) = GenerateAccessToken(userId, userdetails.Email, userdetails.UserRole);
                var updated = await _loginWriter.UpdateRefreshToken(userdetails.Email, refreshTokenHash); // update refresh token created date / ttl

                return new RegistrationResultModel
                {
                    Message = "Access token refreshed.",
                    Email = userdetails.Email,
                    UserId = userId,
                    AccessToken = newAccessToken,
                    RefreshToken = null, // client already holds the same refresh token
                    AccessTokenExpiresAt = newExpiresAt
                };
            }
            catch (Exception ex)
            {
                // Log exception as needed
                return new RegistrationResultModel { Message = "Could not refresh token. Please try again." };
            }
        }
       
        public Task<string> CreateRefreshToken()
        {
            try
            {
                string newtoken = GenerateRefreshToken();
                return Task.FromResult(newtoken);
            }
            catch (Exception ex)
            {
                throw new SystemException(ex.Message);
            }
        }
       
        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
       
        public string HashRefreshToken(string refreshToken)
        {
            // Store this hash in DB, not the raw token
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(refreshToken));
            return Convert.ToBase64String(bytes);
        }
        
        public (string AccessToken, DateTime ExpiresAt) GenerateAccessToken(Guid userId,string email,int roleId)
        {
            var key = Configuration["Jwt:Key"]
                ?? throw new InvalidOperationException("Jwt:Key missing");

            var issuer = Configuration["Jwt:Issuer"];
            var audience = Configuration["Jwt:Audience"];

            var expiresAt = DateTime.UtcNow.AddMinutes(10);

            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, userId.ToString()),
                new(JwtRegisteredClaimNames.Email, email),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),

                // Standard role claim
                new(ClaimTypes.Role, roleId.ToString())
            };

            var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
            var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                notBefore: DateTime.UtcNow,
                expires: expiresAt,
                signingCredentials: creds
            );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);

            return (jwt, expiresAt);
        }

        
    }
}
