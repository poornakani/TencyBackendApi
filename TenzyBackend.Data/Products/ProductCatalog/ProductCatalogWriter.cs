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

            return await _dapper.InsertAsync<int>(
                "spProductCatalog_Insert", p, CommandType.StoredProcedure);
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
    }
}
