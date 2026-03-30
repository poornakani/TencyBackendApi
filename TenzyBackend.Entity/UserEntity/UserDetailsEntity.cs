using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Entity.UserEntity
{
    public class UserDetailsEntity
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }
        public required string UserName { get; set; }
        public required string RefreshToken { get; set; }
    }
}
