using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Entity.UserEntity
{
    public class RefreshTokenUpdateResultEntity
    {
        public bool Success { get; set; }
        public bool WasRotated { get; set; }   
        public string RefreshToken { get; set; } 
        public DateTime ExpiresAtUtc { get; set; }
    }
}
