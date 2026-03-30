using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ProductFAQService
{
    public interface IProductFAQService
    {
        Task<int> CreateProductFAQAsync(ProductFAQModel productFAQModel);
        Task<bool> UpdateProductFAQAsync(ProductFAQModel productFAQModel);
        Task<bool> DeactiveProductFAQAsync(int productFAQId);
        Task<bool> ActiveProductFAQAsync(int productFAQId);
        Task<ProductFAQModel?> GetProductFAQByIdAsync(int productFAQId);
        Task<List<ProductFAQModel>> GetAllProductFAQsAsync();
    }
}
