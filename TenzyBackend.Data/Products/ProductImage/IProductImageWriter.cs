using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductImage
{
    public interface IProductImageWriter
    {
        Task<int> CreateAsync(ProductImageEntity productImageEntity);
        Task<bool> UpdateAsync(ProductImageEntity productImageEntity);
        Task<bool> DeactiveAsync(int productFAQID);
        Task<bool> ActiveAsync(int productFAQID);
    }
}
