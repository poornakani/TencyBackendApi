using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Models.UserModel
{
    public class RefreashToken
    {
        public long Id { get; set; }
        public int UserId { get; set; }

        // Store a HASH of the refresh token (recommended)
        public required string RefreshTokenHash { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime ExpiresAt { get; set; }

        public DateTime? RevokedAt { get; set; }

        
    }
}
