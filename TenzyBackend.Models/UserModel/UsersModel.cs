using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace TenzyBackend.Models.UserModel
{
    public class    UsersModel
    {
        public Guid Id { get; set; }

        [Required, EmailAddress]
        public  string Email { get; set; }

        [Required]
        [StringLength(8, MinimumLength = 8,
         ErrorMessage = "Password must be exactly 8 characters.")]

        //[RegularExpression(
        // @"^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=\[{\]};:<>|./?]).{8}$",
        // ErrorMessage = "Password must contain at least 1 uppercase letter, 1 number, and 1 special character.")]
        public string Password { get; set; }

        public  bool EmailVerified { get; set; }

        public required string DisplayName { get; set; }
        public required int UserRole { get; set; } = 1;
        public required int Status { get; set; } = 1;
        public DateTime CreatedAt { get; set; }
        public DateTime LastLoginAt { get; set; }
    }


}
