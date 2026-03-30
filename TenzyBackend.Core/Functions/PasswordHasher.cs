using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Core.Functions
{
    public class PasswordHasher
    {
        // Hash password (store this in DB)
        public static string Hash(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        // Verify password during login
        public static bool Verify(string password, string hashedPassword)
        {
            return BCrypt.Net.BCrypt.Verify(password, hashedPassword);
        }
    }
}

