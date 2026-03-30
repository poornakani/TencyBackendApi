using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Entity.Enums
{
    public enum UserRoleEnumsEntity
    {
        RegulaeUser=1, //users who registered to purchase items
        Admin=2, // users who has more access for backend
        SuperAdmin = 3 //user who has more access to change in functionalities
    }
}
