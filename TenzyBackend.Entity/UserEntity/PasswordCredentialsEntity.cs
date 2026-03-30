using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Entity.UserEntity
{
    public class PasswordCredentialsEntity
    {
        public required Guid UserId { get; set; }
        public required string PasswordHash { get; set; }
        public DateTime PasswordUpdatedAt { get; set; }
        public int FailedAttempts { get; set; }
        public int LockedUntil { get; set; }
    }
}
