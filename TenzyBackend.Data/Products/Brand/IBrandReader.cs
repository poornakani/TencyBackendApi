using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Brand
{
    public interface IBrandReader
    {
        Task<BrandEntity?> GetByIdAsync(int brandId);
        Task<List<BrandEntity>> GetAllAsync();
    }
}
