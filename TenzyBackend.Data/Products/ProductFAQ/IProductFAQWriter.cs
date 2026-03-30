using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductFAQ
{
    public interface IProductFAQWriter
    {
        Task<int> CreateAsync(ProductFAQEntity productFAQEntity);
        Task<bool> UpdateAsync(ProductFAQEntity productFAQEntity);
        Task<bool> DeactiveAsync(int productFAQID);
        Task<bool> ActiveAsync(int productFAQID);
    }
}
