using Dapper;
using System;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;

namespace TenzyBackend.Data.Products.ProductReview
{
    public class ProductReviewWriter : IProductReviewWriter
    {
        private readonly DapperMethods _dapper;

        public ProductReviewWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<int> CreateReviewAsync(int productId, Guid userId, string displayName,
            byte rate, string? comment, bool isVerifiedPurchase)
        {
            var p = new DynamicParameters();
            p.Add("@ProductId",          productId,          DbType.Int32);
            p.Add("@UserId",             userId,             DbType.Guid);
            p.Add("@DisplayName",        displayName,        DbType.String);
            p.Add("@Rate",               rate,               DbType.Byte);
            p.Add("@Comment",            comment,            DbType.String);
            p.Add("@IsVerifiedPurchase", isVerifiedPurchase, DbType.Boolean);

            return await _dapper.InsertAsync<int>(
                "spProductReview_Insert", p, CommandType.StoredProcedure);
        }

        public async Task<bool> ModerateReviewAsync(int reviewId, bool isApproved)
        {
            var p = new DynamicParameters();
            p.Add("@Id",         reviewId,   DbType.Int32);
            p.Add("@IsApproved", isApproved, DbType.Boolean);

            int rows = await _dapper.ExecuteAsync(
                "spProductReview_Moderate", p, CommandType.StoredProcedure);
            return rows > 0;
        }
    }
}
