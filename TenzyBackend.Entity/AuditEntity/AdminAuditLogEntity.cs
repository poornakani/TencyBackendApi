using System;

namespace TenzyBackend.Entity.AuditEntity
{
    public class AdminAuditLogEntity
    {
        public long Id { get; set; }
        public Guid AdminUserId { get; set; }
        public string AdminName { get; set; } = string.Empty;
        public string Action { get; set; } = string.Empty;
        public string? EntityType { get; set; }
        public string? EntityId { get; set; }
        public string? OldValues { get; set; }
        public string? NewValues { get; set; }
        public string? IpAddress { get; set; }
        public string? UserAgent { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
