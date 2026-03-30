using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductCatalog
{
    public interface IProductCatalogReader
    {
        Task<List<ProductCatalogEntity>> GetAllAsync();
        Task<ProductCatalogEntity?> GetByIdAsync(int productId);
    }
}
