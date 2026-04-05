using Dapper;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Data.Products.ProductCatalog
{
    public class ProductCatalogWriter : IProductCatalogWriter
    {
        private readonly DapperMethods _dapper;

        public ProductCatalogWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<int> CreateAsync(CreateProductRequest request)
        {
            var concernIds = NormalizeConcernIds(request.ConcernTypeIds);
            var concernCsv = concernIds.Count > 0
                ? string.Join(",", concernIds)
                : null;

            var p = new DynamicParameters();
            p.Add("@Name",           request.Name,          DbType.String);
            p.Add("@BrandId",        request.BrandId,       DbType.Int32);
            p.Add("@CategoryId",     request.CategoryId,    DbType.Int32);
            p.Add("@Description",    request.Description,   DbType.String);
            p.Add("@Weight",         request.Weight,        DbType.Decimal);
            p.Add("@InSale",         request.InSale,        DbType.Boolean);
            p.Add("@SellingPrice",   request.SellingPrice,  DbType.Decimal);
            p.Add("@OriginalPrice",  request.OriginalPrice, DbType.Decimal);
            p.Add("@StockQuantity",  request.StockQuantity, DbType.Int32);
            p.Add("@StartUTC",       request.StartUTC,      DbType.DateTime2);
            p.Add("@EndUTC",         request.EndUTC,        DbType.DateTime2);
            p.Add("@ConcernTypeIds", concernCsv,            DbType.String);

            var newId = await _dapper.InsertAsync<int>(
                "spProductCatalog_Insert", p, CommandType.StoredProcedure);
            await SyncProductConcernsAsync(newId, concernIds, replaceExisting: true);
            await SyncProductPaymentOptionsAsync(newId, request.PaymentOptions);
            return newId;
        }

        public async Task<bool> UpdateAsync(UpdateProductRequest request)
        {
            // Pass NULL when no concern list supplied so the SP leaves concerns unchanged.
            // Pass empty string when the list is explicitly empty (clears all concerns).
            var concernIds = NormalizeConcernIds(request.ConcernTypeIds);
            string? concernCsv = request.ConcernTypeIds != null
                ? string.Join(",", concernIds)
                : null;

            var p = new DynamicParameters();
            p.Add("@ProductId",      request.ProductId,     DbType.Int32);
            p.Add("@Name",           request.Name,          DbType.String);
            p.Add("@BrandId",        request.BrandId,       DbType.Int32);
            p.Add("@CategoryId",     request.CategoryId,    DbType.Int32);
            p.Add("@Description",    request.Description,   DbType.String);
            p.Add("@Weight",         request.Weight,        DbType.Decimal);
            p.Add("@InSale",         request.InSale,        DbType.Boolean);
            p.Add("@SellingPrice",   request.SellingPrice,  DbType.Decimal);
            p.Add("@OriginalPrice",  request.OriginalPrice, DbType.Decimal);
            p.Add("@StockQuantity",  request.StockQuantity, DbType.Int32);
            p.Add("@StartUTC",       request.StartUTC,      DbType.DateTime2);
            p.Add("@EndUTC",         request.EndUTC,        DbType.DateTime2);
            p.Add("@ConcernTypeIds", concernCsv,            DbType.String);

            await _dapper.ExecuteAsync(
                "spProductCatalog_Update", p, CommandType.StoredProcedure);
            await SyncProductConcernsAsync(request.ProductId, concernIds, replaceExisting: request.ConcernTypeIds != null);
            await SyncProductPaymentOptionsAsync(request.ProductId, request.PaymentOptions);
            return true;
        }

        public async Task<bool> DeactivateAsync(int productId)
        {
            var p = new DynamicParameters();
            p.Add("@ProductId", productId, DbType.Int32);

            int rows = await _dapper.ExecuteAsync(
                "spProductCatalog_Deactivate", p, CommandType.StoredProcedure);
            return rows > 0;
        }

        private async Task SyncProductConcernsAsync(int productId, IReadOnlyList<int> concernIds, bool replaceExisting)
        {
            if (!replaceExisting) return;

            var p = new DynamicParameters();
            p.Add("@ProductId", productId, DbType.Int32);
            await _dapper.ExecuteAsync(@"
IF OBJECT_ID('dbo.ProductConcerns', 'U') IS NULL
    RETURN;

DELETE FROM dbo.ProductConcerns
WHERE productid = @ProductId;", p, CommandType.Text);

            foreach (var concernId in concernIds)
            {
                var insertParams = new DynamicParameters();
                insertParams.Add("@ProductId", productId, DbType.Int32);
                insertParams.Add("@ConcernId", concernId, DbType.Int32);

                await _dapper.ExecuteAsync(@"
IF OBJECT_ID('dbo.ProductConcerns', 'U') IS NULL
    RETURN;

IF (
    (OBJECT_ID('dbo.ConcernTypes', 'U') IS NOT NULL AND EXISTS (
        SELECT 1 FROM dbo.ConcernTypes WHERE ConcernTypeId = @ConcernId
    ))
    OR
    (OBJECT_ID('dbo.ConcernType', 'U') IS NOT NULL AND EXISTS (
        SELECT 1 FROM dbo.ConcernType WHERE ConcernTypeId = @ConcernId
    ))
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductConcerns
    WHERE productid = @ProductId AND concernID = @ConcernId
)
BEGIN
    INSERT INTO dbo.ProductConcerns (productid, concernID)
    VALUES (@ProductId, @ConcernId);
END", insertParams, CommandType.Text);
            }
        }

        private async Task SyncProductPaymentOptionsAsync(int productId, List<ProductPaymentOptionRequest>? paymentOptions)
        {
            if (paymentOptions == null) return;

            var delParams = new DynamicParameters();
            delParams.Add("@ProductId", productId, DbType.Int32);
            await _dapper.ExecuteAsync(
                @"IF OBJECT_ID('dbo.ProductPaymentOptions', 'U') IS NULL
                      RETURN;

                  DELETE FROM dbo.ProductPaymentOptions
                  WHERE productid = @ProductId",
                delParams, CommandType.Text);

            var seen = new System.Collections.Generic.HashSet<int>();
            foreach (var opt in paymentOptions.Where(o => o != null && o.PaymentTypeId > 0))
            {
                if (!seen.Add(opt.PaymentTypeId)) continue;
                var ins = new DynamicParameters();
                ins.Add("@ProductId",     productId,        DbType.Int32);
                ins.Add("@PaymentTypeId", opt.PaymentTypeId, DbType.Int32);
                ins.Add("@Instalment",    opt.Instalment,   DbType.Int32);
                await _dapper.ExecuteAsync(
                    @"IF OBJECT_ID('dbo.ProductPaymentOptions', 'U') IS NULL
                          RETURN;

                      IF EXISTS (SELECT 1 FROM dbo.PaymentType WHERE PaymentTypeId = @PaymentTypeId AND IsActive = 1)
                      INSERT INTO dbo.ProductPaymentOptions (productid, PaymentTypeId, instalment)
                      VALUES (@ProductId, @PaymentTypeId, @Instalment);",
                    ins, CommandType.Text);
            }
        }

        private static List<int> NormalizeConcernIds(List<int>? concernTypeIds)
        {
            return (concernTypeIds ?? new List<int>())
                .Where(id => id > 0)
                .Distinct()
                .ToList();
        }
    }
}
