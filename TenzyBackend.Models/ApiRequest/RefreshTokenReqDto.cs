using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.Enums;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Models.ApiRequest
{
    public sealed record RefreshTokenReqDto
    {
        public required Guid UserID { get; set; }
        public required string RefreshTokenHash { get; set; }
    }
}
