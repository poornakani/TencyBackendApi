using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductPricingEntity
    {
        [Key]
        [Column("PricingId")]
        public int PricingId { get; set; }

        [Required]
        [Column("productid")]
        public int ProductId { get; set; }

        [Required]
        [Column("price", TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }

        [Required]
        [Column("discountrate", TypeName = "decimal(5,2)")]
        public decimal DiscountRate { get; set; }

        [Required]
        [Column("StartUTC")]
        public DateTime StartUtc { get; set; }

        [Column("EndUTC")]
        public DateTime? EndUtc { get; set; }

        [Required]
        [Column("createdate")]
        public DateTime CreateDate { get; set; }

        [Column("lastupdated")]
        public DateTime? LastUpdated { get; set; }

        public virtual ProductCatalogEntity? ProductCatalog { get; set; }
    }
}
