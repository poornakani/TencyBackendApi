using System;

namespace TenzyBackend.Models.ProductsModels
{
    public class ProductCatalogModel
    {
        public int ProductId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int BrandId { get; set; }
        public string? BrandName { get; set; }
        public int CategoryId { get; set; }
        public string? CategoryName { get; set; }
        public string? Description { get; set; }
        public decimal? Weight { get; set; }
        public bool InSale { get; set; }
        public DateTime CreateDate { get; set; }
        public DateTime? LastUpdated { get; set; }

        // Inventory
        public int StockQuantity { get; set; }

        // Pricing
        public decimal SellingPrice { get; set; }
        public decimal OriginalPrice { get; set; }
        public decimal DiscountRate { get; set; }
        public DateTime? StartUTC { get; set; }
        public DateTime? EndUTC { get; set; }

        // Primary image (from ProductImages)
        public string? PrimaryImageUrl { get; set; }
    }

    public class CreateProductRequest
    {
        public string Name { get; set; } = string.Empty;
        public int BrandId { get; set; }
        public int CategoryId { get; set; }
        public string? Description { get; set; }
        public decimal? Weight { get; set; }
        public bool InSale { get; set; } = true;
        public decimal SellingPrice { get; set; }
        public decimal OriginalPrice { get; set; }
        public int StockQuantity { get; set; }
    }

    public class UpdateProductRequest
    {
        public int ProductId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int BrandId { get; set; }
        public int CategoryId { get; set; }
        public string? Description { get; set; }
        public decimal? Weight { get; set; }
        public bool InSale { get; set; } = true;
        public decimal? SellingPrice { get; set; }
        public decimal? OriginalPrice { get; set; }
        public int? StockQuantity { get; set; }
    }
}
