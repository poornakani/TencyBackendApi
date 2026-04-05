using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Data.Products.ProductCatalog
{
    public interface IProductCatalogReader
    {
        Task<List<ProductCatalogEntity>> GetAllAsync();
        Task<List<ProductCatalogEntity>> GetAllAdminAsync();
        Task<ProductCatalogEntity?> GetByIdAsync(int productId);
        Task<List<int>> GetProductConcernIdsAsync(int productId);
        Task<List<ProductPaymentOptionModel>> GetProductPaymentOptionsAsync(int productId);
    }
}
