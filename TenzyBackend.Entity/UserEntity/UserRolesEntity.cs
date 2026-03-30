using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Entity.UserEntity
{
    public class UserRolesEntity
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }
        public DateTime AssignedAt { get; set; }

    }
}
