using Dapper;
using System.Data;
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
            var concernCsv = request.ConcernTypeIds != null && request.ConcernTypeIds.Count > 0
                ? string.Join(",", request.ConcernTypeIds)
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
            await SyncProductConcernsAsync(newId, concernCsv, replaceExisting: true);
            return newId;
        }

        public async Task<bool> UpdateAsync(UpdateProductRequest request)
        {
            // Pass NULL when no concern list supplied so the SP leaves concerns unchanged.
            // Pass empty string when the list is explicitly empty (clears all concerns).
            string? concernCsv = null;
            if (request.ConcernTypeIds != null)
                concernCsv = string.Join(",", request.ConcernTypeIds);

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
            await SyncProductConcernsAsync(request.ProductId, concernCsv, replaceExisting: request.ConcernTypeIds != null);
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

        private async Task SyncProductConcernsAsync(int productId, string? concernCsv, bool replaceExisting)
        {
            if (!replaceExisting) return;

            var p = new DynamicParameters();
            p.Add("@ProductId", productId, DbType.Int32);
            p.Add("@ConcernTypeIds", concernCsv, DbType.String);

            const string sql = @"
IF OBJECT_ID('dbo.ProductConcerns', 'U') IS NULL
    RETURN;

DELETE FROM dbo.ProductConcerns
WHERE productid = @ProductId;

IF @ConcernTypeIds IS NULL OR LTRIM(RTRIM(@ConcernTypeIds)) = ''
    RETURN;

;WITH ParsedConcernIds AS (
    SELECT DISTINCT TRY_CAST(LTRIM(RTRIM(value)) AS INT) AS ConcernTypeId
    FROM STRING_SPLIT(@ConcernTypeIds, ',')
)
INSERT INTO dbo.ProductConcerns (productid, concernID)
SELECT @ProductId, ids.ConcernTypeId
FROM ParsedConcernIds ids
WHERE ids.ConcernTypeId IS NOT NULL
  AND (
        (OBJECT_ID('dbo.ConcernTypes', 'U') IS NOT NULL AND EXISTS (
            SELECT 1 FROM dbo.ConcernTypes ct WHERE ct.ConcernTypeId = ids.ConcernTypeId
        ))
        OR
        (OBJECT_ID('dbo.ConcernType', 'U') IS NOT NULL AND EXISTS (
            SELECT 1 FROM dbo.ConcernType ct WHERE ct.ConcernTypeId = ids.ConcernTypeId
        ))
      );";

            await _dapper.ExecuteAsync(sql, p, CommandType.Text);
        }
    }
}
