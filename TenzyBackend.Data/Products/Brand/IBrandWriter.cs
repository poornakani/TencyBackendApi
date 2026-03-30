using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Brand
{
    public interface IBrandWriter
    {
        Task<int> CreateAsync(BrandEntity entity);
        Task<bool> UpdateAsync(BrandEntity entity);
        Task<bool> DeleteAsync(int brandId);

    }
}
