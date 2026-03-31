using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ReviewService
{
    public interface IReviewService
    {
        Task<ProductReviewListModel> GetProductReviewsAsync(int productId);
        Task<List<ProductReviewModel>> GetAllReviewsAsync(int page, int pageSize, bool? isApproved);
        Task<int> AddReviewAsync(CreateReviewRequest request, Guid userId, string displayName);
        Task<bool> ModerateReviewAsync(int reviewId, bool isApproved);
    }
}
