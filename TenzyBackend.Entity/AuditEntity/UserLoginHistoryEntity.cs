using System;

namespace TenzyBackend.Entity.AuditEntity
{
    public class UserLoginHistoryEntity
    {
        public long Id { get; set; }
        public Guid? UserId { get; set; }
        public string Email { get; set; } = string.Empty;
        public bool IsSuccess { get; set; }
        public string? FailReason { get; set; }
        public string? IpAddress { get; set; }
        public string? UserAgent { get; set; }
        public DateTime AttemptedAt { get; set; }
    }
}
