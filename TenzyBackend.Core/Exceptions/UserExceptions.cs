using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Core.Exceptions
{
    public class UserExceptions(string userEmail) : Exception($"User is already registered {userEmail}");
    
}
