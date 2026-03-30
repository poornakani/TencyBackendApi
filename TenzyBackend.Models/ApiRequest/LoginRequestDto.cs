using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Models.ApiRequest
{
    public sealed record LoginRequestDto(string Email, string Password);
}
