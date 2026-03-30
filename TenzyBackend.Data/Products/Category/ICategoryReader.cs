using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Category
{
    public interface ICategoryReader
    {
        Task<CategoryEntity?> GetByIdAsync(int catId);
        Task<List<CategoryEntity>> GetAllAsync();
    }
}
