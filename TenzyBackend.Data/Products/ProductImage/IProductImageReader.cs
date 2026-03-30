using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductImage
{
    public interface IProductImageReader
    {
        Task<ProductImageEntity?> GetByIdAsync(int productimageId);
        Task<List<ProductImageEntity>> GetAllAsync();
    }
}
