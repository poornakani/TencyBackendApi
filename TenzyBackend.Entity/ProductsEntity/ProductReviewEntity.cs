using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductReviewEntity
    {
        [Key]
        [Column("ID")]
        public int Id { get; set; }

        [Required]
        [Column("productid")]
        public int ProductId { get; set; }

        [Required]
        [Column("userid")]
        public Guid UserId { get; set; }

        [Required]
        [Column("rate")]
        public byte Rate { get; set; }

        [Column("comment")]
        [StringLength(2000)]
        public string? Comment { get; set; }

        [Required]
        [Column("createdUTC")]
        public DateTime CreatedUtc { get; set; }

        public virtual ProductCatalogEntity? ProductCatalog { get; set; }
    }
}
