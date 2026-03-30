using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Models.UserModel
{
    public class UserRolesModel
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }
        public DateTime AssignedAt { get; set; }


    }
}
