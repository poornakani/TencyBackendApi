using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Models.UserModel
{
    public class PasswordLockRowEntity
    {
        public int FailedAttempts { get; set; }
        public DateTime? LockedUntil { get; set; }
    }
}
