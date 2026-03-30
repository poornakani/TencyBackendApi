using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Category
{
    public interface ICategoryWriter
    {
        Task<int> CreateAsync(CategoryEntity catentity);
        Task<bool> UpdateAsync(CategoryEntity catentity);
        Task<bool> DeactiveAsync(int catID);
        Task<bool> ActiveAsync(int catID);
    }
}
