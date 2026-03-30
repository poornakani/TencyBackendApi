using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.Enums;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Models.ApiRequest
{
    public sealed record RegisterDto
    {
        public required UsersModel User { get; init; }
        public required UserRoleEnumsModel Role { get; init; }
    }
}
