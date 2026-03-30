using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductFAQ
{
    public interface IProductFAQReader
    {
        Task<ProductFAQEntity?> GetByIdAsync(int productFAQId);
        Task<List<ProductFAQEntity>> GetAllAsync();
    }
}
