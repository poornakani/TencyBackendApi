using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductCatalogEntity
    {
        [Key]
        [Column("productid")]
        public int ProductId { get; set; }

        [Required]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Column("brandid")]
        public int BrandId { get; set; }

        [Required]
        [Column("categoryid")]
        public int CategoryId { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("weight", TypeName = "decimal(18,3)")]
        public decimal? Weight { get; set; }

        [Required]
        [Column("insale")]
        public bool InSale { get; set; }

        [Required]
        [Column("createdate")]
        public DateTime CreateDate { get; set; }

        [Column("lastupdated")]
        public DateTime? LastUpdated { get; set; }

        public virtual BrandEntity? Brand { get; set; }

        public virtual CategoryEntity? Category { get; set; }

        // Populated by stored procedures via JOIN — not EF columns
        public string? BrandName { get; set; }
        public string? CategoryName { get; set; }
        public int StockQuantity { get; set; }
        public decimal SellingPrice { get; set; }
        public decimal OriginalPrice { get; set; }
        public decimal DiscountRate { get; set; }
        public DateTime? StartUTC { get; set; }
        public DateTime? EndUTC { get; set; }
        public string? PrimaryImageUrl { get; set; }
        public string? ConcernTypeIdsCsv { get; set; }
    }
}
