using System;
using System.Threading.Tasks;

namespace TenzyBackend.Data.Products.ProductReview
{
    public interface IProductReviewWriter
    {
        Task<int> CreateReviewAsync(int productId, Guid userId, string displayName, byte rate, string? comment, bool isVerifiedPurchase);
        Task<bool> ModerateReviewAsync(int reviewId, bool isApproved);
    }
}
