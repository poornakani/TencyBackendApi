using Dapper;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Data.Products.ProductReview
{
    public class ProductReviewReader : IProductReviewReader
    {
        private readonly DapperMethods _dapper;

        public ProductReviewReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<ProductReviewListModel> GetByProductAsync(int productId)
        {
            // SP returns two result sets: reviews list + aggregate (count + avg)
            using var db = _dapper._context.CreateConnection();
            if (db.State == ConnectionState.Closed) db.Open();

            var p = new DynamicParameters();
            p.Add("@ProductId", productId, DbType.Int32);

            using var multi = await db.QueryMultipleAsync(
                "spProductReview_GetByProduct", p, commandType: CommandType.StoredProcedure);

            var reviews   = (await multi.ReadAsync<ProductReviewFullEntity>()).ToList();
            var aggregate = (await multi.ReadAsync<ReviewAggregateEntity>()).FirstOrDefault();

            return new ProductReviewListModel
            {
                Reviews      = reviews.Select(r => new ProductReviewModel
                {
                    Id                 = r.Id,
                    ProductId          = r.ProductId,
                    UserId             = r.UserId,
                    DisplayName        = r.DisplayName,
                    Rate               = r.Rate,
                    Comment            = r.Comment,
                    IsVerifiedPurchase = r.IsVerifiedPurchase,
                    IsApproved         = r.IsApproved,
                    CreatedAt          = r.CreatedAt
                }).ToList(),
                TotalReviews = aggregate?.TotalReviews ?? 0,
                AvgRating    = aggregate?.AvgRating    ?? 0
            };
        }

        public async Task<List<ProductReviewFullEntity>> GetAllAsync(int pageSize, int offset, bool? isApproved)
        {
            var p = new DynamicParameters();
            p.Add("@PageSize",   pageSize,   DbType.Int32);
            p.Add("@Offset",     offset,     DbType.Int32);
            p.Add("@IsApproved", isApproved, DbType.Boolean);

            return await _dapper.GetAllAsync<ProductReviewFullEntity>(
                "spProductReview_GetAll", p, CommandType.StoredProcedure);
        }
    }
}
