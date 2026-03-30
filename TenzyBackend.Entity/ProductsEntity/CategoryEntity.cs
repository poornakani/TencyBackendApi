using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class CategoryEntity
    {
        [Key]
        [Column("catagoryID")]
        public int CategoryId { get; set; }

        [Required]
        [Column("categorytype")]
        public string CategoryType { get; set; } = string.Empty;

        public bool IsActive { get; set; }
    }
}
