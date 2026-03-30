using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductImageEntity
    {
        [Key]
        [Column("ImageId")]
        public int ImageId { get; set; }

        [Required]
        [Column("productid")]
        public int ProductId { get; set; }

        [Required]
        [Column("ImageUrl")]
        public string ImageUrl { get; set; } = string.Empty;

        [Required]
        [Column("IsPrimary")]
        public bool IsPrimary { get; set; }

        [Required]
        [Column("SortOrder")]
        public int SortOrder { get; set; }

        [Required]
        [Column("createdate")]
        public DateTime CreateDate { get; set; }

        public bool IsActive { get; set; }
    }
}
