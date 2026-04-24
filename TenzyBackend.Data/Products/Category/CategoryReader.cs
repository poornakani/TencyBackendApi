using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System.Collections.Generic;
using System.Data;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Category
{
    public class CategoryReader : ReaderBase<CategoryEntity, int, CategoryReader>, ICategoryReader
    {
        public CategoryReader(DapperMethods dapperMethods, ILogger<CategoryReader> logger)
           : base(dapperMethods, logger)
        {
        }

        protected override string GetByIdProcedureName => "sp_Category_GetById";
        protected override string GetAllProcedureName  => "sp_Category_GetAllActive";
        protected override string IdParameterName      => "@CategoryId";

        // Override with raw SQL to fix DB column name typo.
        // The DB column is "catagoryID" (typo), which Dapper cannot match
        // to the "CategoryId" property by name, so we alias it explicitly.
        private const string SelectColumns = @"
            CategoryID   AS CategoryId,
            categorytype AS CategoryType,
            isactive     AS IsActive";

        public override async Task<List<CategoryEntity>> GetAllAsync()
        {
            const string sql = $"SELECT {SelectColumns} FROM dbo.Category WHERE isactive = 1 ORDER BY categorytype";
            return await _dapperPro.GetAllAsync<CategoryEntity>(sql, commandType: CommandType.Text);
        }

        public override async Task<CategoryEntity?> GetByIdAsync(int id)
        {
            const string sql = $"SELECT {SelectColumns} FROM dbo.Category WHERE CategoryID = @CategoryId";
            var parms = new DynamicParameters();
            parms.Add("@CategoryId", id);
            return await _dapperPro.GetAsync<CategoryEntity>(sql, parms, commandType: CommandType.Text);
        }
    }
}
