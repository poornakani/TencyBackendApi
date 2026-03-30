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
        public bool InSale { get; set; } = true;
        public DateTime CreateDate { get; set; }
        public DateTime? LastUpdated { get; set; }

        // From ProductInventory
        public int StockQuantity { get; set; }

        // From ProductPricing
        public decimal SellingPrice { get; set; }
        public decimal OriginalPrice { get; set; }
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
    }
}
