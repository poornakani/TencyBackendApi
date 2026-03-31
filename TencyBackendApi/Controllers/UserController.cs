using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.TokenService;
using TenzyBackend.Models.ApiRequest;
using TenzyBackend.Models.ApiResponseModels;
using TenzyBackend.Models.Enums;
using TenzyBackend.Models.UserModel;

namespace TencyBackendApi.Controllers
{
    [Route("api/userlogin")]
    [ApiController]
    public class UserController : ControllerBase
    {
        public readonly ITokenservice _tokenservice;
        ApiResponseModel apiResponseModel = new ApiResponseModel();

        public UserController(ITokenservice tokenservice)
        {
            _tokenservice = tokenservice;
        }


        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] UsersModel usersModel)
        {

            var Userdetails = await _tokenservice.UserRegistration(usersModel);
            if (Userdetails.Message != "User registered successfully.")
                return BadRequest(Userdetails);

            if (!string.IsNullOrWhiteSpace(Userdetails.RefreshToken))
            {
                Response.Cookies.Append("refresh_token", Userdetails.RefreshToken, new CookieOptions
                {
                    HttpOnly = true,
                    Secure = false, // HTTPS
                    SameSite = SameSiteMode.Strict,
                    Expires = DateTimeOffset.UtcNow.AddDays(14),
                    Path = "/"
                });
            }

            return Ok(new
            {
                accessToken = Userdetails.AccessToken,
                expiresAtUtc = Userdetails.AccessTokenExpiresAt,
                user = new { id = Userdetails.UserId, email = Userdetails.Email,roleId= Userdetails.RoleId,userName = Userdetails.Username,
                    refreshHasToken=Userdetails.RefreshToken }
            });

        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> UserLoginController([FromBody] LoginRequestDto request)
        {

            var apiResponseModel = new ApiResponseModel();

            try
            {
                if (request is null ||
                    string.IsNullOrWhiteSpace(request.Email) ||
                    string.IsNullOrWhiteSpace(request.Password))
                {
                    apiResponseModel.result = false;
                    apiResponseModel.message = "Please enter valid Email and Password";
                    apiResponseModel.response = null;
                    return BadRequest(apiResponseModel);
                }

                // Call your service (this returns AccessToken + RefreshToken raw)
                var loginResult = await _tokenservice.UserLogin(request.Email, request.Password);

                // If login failed
                if (loginResult == null || string.IsNullOrWhiteSpace(loginResult.AccessToken))
                {
                    apiResponseModel.result = false;
                    apiResponseModel.message = loginResult?.Message ?? "Invalid email or password";
                    apiResponseModel.response = null;
                    return Unauthorized(apiResponseModel);
                }

                //  SET refresh token in HttpOnly cookie (web best practice)
                if (!string.IsNullOrWhiteSpace(loginResult.RefreshToken))
                {
                    var refreshExpiry = DateTimeOffset.UtcNow.AddDays(14);

                    Response.Cookies.Append("refresh_token", loginResult.RefreshToken, new CookieOptions
                    {
                        HttpOnly = true,
                        Secure = false,                 // HTTPS only in production
                        SameSite = SameSiteMode.Strict,
                        Expires = refreshExpiry,
                        Path = "/"
                    });
                }

                //  Return only safe data to frontend (do not return refresh token in JSON)
                apiResponseModel.result = true;
                apiResponseModel.message = loginResult.Message;

                apiResponseModel.response = new
                {
                    accessToken = loginResult.AccessToken,
                    expiresAtUtc = loginResult.AccessTokenExpiresAt,
                    user = new
                    {
                        id = loginResult.UserId,
                        email = loginResult.Email,
                        roleId= loginResult.RoleId,
                        userName = loginResult.Username,
                        refreshHasToken = loginResult.RefreshToken
                    }
                };

                return Ok(apiResponseModel);


            }
            catch (Exception ex)
            {
                apiResponseModel.result = false;
                apiResponseModel.message = "Login failed";
                apiResponseModel.response = null;

                // log ex
                return StatusCode(500, apiResponseModel);
            }


        }

        [HttpPost("forgot-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            var api = new ApiResponseModel();
            if (string.IsNullOrWhiteSpace(request?.Email))
            {
                api.result = false;
                api.message = "Email is required.";
                return BadRequest(api);
            }

            await _tokenservice.ForgotPasswordAsync(request.Email);

            // Always return success to avoid email enumeration
            api.result = true;
            api.message = "If that email exists, a reset link has been sent.";
            return Ok(api);
        }

        [HttpPost("reset-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            var api = new ApiResponseModel();
            if (string.IsNullOrWhiteSpace(request?.Token) ||
                string.IsNullOrWhiteSpace(request.NewPassword))
            {
                api.result = false;
                api.message = "Token and new password are required.";
                return BadRequest(api);
            }

            var ok = await _tokenservice.ResetPasswordAsync(request.Token, request.NewPassword);
            if (!ok)
            {
                api.result = false;
                api.message = "Invalid or expired reset token.";
                return BadRequest(api);
            }

            api.result = true;
            api.message = "Password reset successfully.";
            return Ok(api);
        }

        [HttpPost("refreshtoken")]
        [AllowAnonymous]
        public async Task<IActionResult> UserRefreshToken([FromBody] RefreshTokenReqDto refreshTokenReqDto)
        {
            var apiResponseModel = new ApiResponseModel();
            try
            {
                var refreshResult = await _tokenservice.GetRefreshToken(refreshTokenReqDto.UserID, refreshTokenReqDto.RefreshTokenHash);
                if (refreshResult == null || string.IsNullOrWhiteSpace(refreshResult.AccessToken))
                {
                    apiResponseModel.result = false;
                    apiResponseModel.message = refreshResult?.Message ?? "Invalid refresh token";
                    apiResponseModel.response = null;
                    return Unauthorized(apiResponseModel);
                }
                apiResponseModel = new ApiResponseModel
                {
                    result = true,
                    message = refreshResult.Message,
                    response = new
                    {
                        accessToken = refreshResult.AccessToken,
                        expiresAtUtc = refreshResult.AccessTokenExpiresAt
                    }
                };
                return Ok(apiResponseModel);
            }
            catch (Exception ex)
            {
                apiResponseModel.result = false;
                apiResponseModel.message = ex.Message;
                apiResponseModel.response = null;
            }
            return Ok(apiResponseModel);
        }
    }
}
