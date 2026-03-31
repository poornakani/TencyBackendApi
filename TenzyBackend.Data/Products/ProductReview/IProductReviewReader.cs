using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Data.Products.ProductReview
{
    public interface IProductReviewReader
    {
        Task<ProductReviewListModel> GetByProductAsync(int productId);
        Task<List<ProductReviewFullEntity>> GetAllAsync(int pageSize, int offset, bool? isApproved);
    }
}
