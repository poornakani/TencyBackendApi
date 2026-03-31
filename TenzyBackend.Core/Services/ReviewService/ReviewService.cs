using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.ProductReview;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ReviewService
{
    public class ReviewService : IReviewService
    {
        private readonly IProductReviewReader _reader;
        private readonly IProductReviewWriter _writer;
        private readonly IObjectMapper _mapper;

        public ReviewService(IProductReviewReader reader, IProductReviewWriter writer, IObjectMapper mapper)
        {
            _reader = reader;
            _writer = writer;
            _mapper = mapper;
        }

        public Task<ProductReviewListModel> GetProductReviewsAsync(int productId)
        {
            if (productId <= 0) throw new ValidationException("Invalid product id.");
            return _reader.GetByProductAsync(productId);
        }

        public async Task<List<ProductReviewModel>> GetAllReviewsAsync(int page, int pageSize, bool? isApproved)
        {
            if (page < 1) page = 1;
            if (pageSize is < 1 or > 100) pageSize = 50;
            int offset = (page - 1) * pageSize;

            var entities = await _reader.GetAllAsync(pageSize, offset, isApproved);
            return _mapper.Map<List<ProductReviewFullEntity>, List<ProductReviewModel>>(entities);
        }

        public async Task<int> AddReviewAsync(CreateReviewRequest request, Guid userId, string displayName)
        {
            if (request.ProductId <= 0) throw new ValidationException("Invalid product id.");
            if (request.Rate < 1 || request.Rate > 5) throw new ValidationException("Rating must be between 1 and 5.");
            if (string.IsNullOrWhiteSpace(displayName)) displayName = "Anonymous";

            return await _writer.CreateReviewAsync(
                request.ProductId, userId, displayName, request.Rate, request.Comment, false);
        }

        public async Task<bool> ModerateReviewAsync(int reviewId, bool isApproved)
        {
            if (reviewId <= 0) throw new ValidationException("Invalid review id.");
            return await _writer.ModerateReviewAsync(reviewId, isApproved);
        }
    }
}
