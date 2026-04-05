using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ProductCatalogService
{
    public interface IProductCatalogService
    {
        Task<List<ProductCatalogModel>> GetAllProductsAsync();
        Task<List<ProductCatalogModel>> GetAllProductsAdminAsync();
        Task<ProductCatalogModel> GetProductByIdAsync(int productId);
        Task<int> CreateProductAsync(CreateProductRequest request);
        Task<bool> UpdateProductAsync(UpdateProductRequest request);
        Task<bool> DeactivateProductAsync(int productId);
        Task<List<int>> GetProductConcernIdsAsync(int productId);
        Task<List<ProductPaymentOptionModel>> GetProductPaymentOptionsAsync(int productId);
    }
}
