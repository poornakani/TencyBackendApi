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
            var p = new DynamicParameters();
            p.Add("@Name",          request.Name,          DbType.String);
            p.Add("@BrandId",       request.BrandId,       DbType.Int32);
            p.Add("@CategoryId",    request.CategoryId,    DbType.Int32);
            p.Add("@Description",   request.Description,   DbType.String);
            p.Add("@Weight",        request.Weight,        DbType.Decimal);
            p.Add("@InSale",        request.InSale,        DbType.Boolean);
            p.Add("@SellingPrice",  request.SellingPrice,  DbType.Decimal);
            p.Add("@OriginalPrice", request.OriginalPrice, DbType.Decimal);
            p.Add("@StockQuantity", request.StockQuantity, DbType.Int32);

            return await _dapper.InsertAsync<int>(
                "spProductCatalog_Insert", p, CommandType.StoredProcedure);
        }

        public async Task<bool> UpdateAsync(UpdateProductRequest request)
        {
            var p = new DynamicParameters();
            p.Add("@ProductId",     request.ProductId,     DbType.Int32);
            p.Add("@Name",          request.Name,          DbType.String);
            p.Add("@BrandId",       request.BrandId,       DbType.Int32);
            p.Add("@CategoryId",    request.CategoryId,    DbType.Int32);
            p.Add("@Description",   request.Description,   DbType.String);
            p.Add("@Weight",        request.Weight,        DbType.Decimal);
            p.Add("@InSale",        request.InSale,        DbType.Boolean);
            p.Add("@SellingPrice",  request.SellingPrice,  DbType.Decimal);
            p.Add("@OriginalPrice", request.OriginalPrice, DbType.Decimal);
            p.Add("@StockQuantity", request.StockQuantity, DbType.Int32);

            int rows = await _dapper.UpdateAsync<int>(
                "spProductCatalog_Update", p, CommandType.StoredProcedure);
            return rows > 0;
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
