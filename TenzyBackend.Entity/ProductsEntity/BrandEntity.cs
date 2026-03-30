using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class BrandEntity
    {
        [Key]
        [Column("Brandid")]
        public int BrandId { get; set; }

        [Required]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Column("barndimage")]
        [StringLength(500)]
        public string? BrandImage { get; set; }

        [Required]
        [Column("createdate")]
        public DateTime CreateDate { get; set; }

        [Column("lastupdated")]
        public DateTime? LastUpdated { get; set; }

        [Column("Isactive")]
        public bool IsActive { get; set; }  
    }
}
