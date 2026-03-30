using System.Threading.Tasks;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Data.Products.ProductCatalog
{
    public interface IProductCatalogWriter
    {
        Task<int> CreateAsync(CreateProductRequest request);
        Task<bool> UpdateAsync(UpdateProductRequest request);
        Task<bool> DeactivateAsync(int productId);
    }
}
