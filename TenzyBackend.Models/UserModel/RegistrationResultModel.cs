using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Models.UserModel
{
    public class RegistrationResultModel
    {
        public string Message { get; set; } = "";
        public string? Email { get; set; }
        public Guid? UserId { get; set; }
        public string Username { get; set; }
        public int RoleId { get; set; }
        public string? AccessToken { get; set; }
        public DateTime? AccessTokenExpiresAt { get; set; }
        public string? RefreshToken { get; set; }
        public List<string>? Errors { get; set; }
    }
}
