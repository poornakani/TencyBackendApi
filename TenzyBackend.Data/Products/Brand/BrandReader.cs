using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System.Collections.Generic;
using System.Data;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Brand
{
    public class BrandReader : ReaderBase<BrandEntity, int, BrandReader>, IBrandReader
    {
        public BrandReader(DapperMethods dapperMethods, ILogger<BrandReader> logger)
            : base(dapperMethods, logger)
        {
        }

        protected override string GetByIdProcedureName => "sp_Brand_GetById";
        protected override string GetAllProcedureName  => "sp_Brand_GetAll";
        protected override string IdParameterName      => "@BrandId";

        // Override with raw SQL to guarantee correct column→property mapping.
        // The DB column is named "barndimage" (typo), which Dapper cannot match
        // to the "BrandImage" property by name, so we alias it explicitly here.
        private const string SelectColumns = @"
            Brandid     AS BrandId,
            name        AS Name,
            barndimage  AS BrandImage,
            createdate  AS CreateDate,
            lastupdated AS LastUpdated,
            Isactive    AS IsActive";

        public override async Task<List<BrandEntity>> GetAllAsync()
        {
            const string sql = $"SELECT {SelectColumns} FROM Brand WHERE Isactive = 1 ORDER BY createdate DESC";
            return await _dapperPro.GetAllAsync<BrandEntity>(sql, commandType: CommandType.Text);
        }

        public override async Task<BrandEntity?> GetByIdAsync(int id)
        {
            const string sql = $"SELECT {SelectColumns} FROM Brand WHERE Brandid = @BrandId";
            var parms = new DynamicParameters();
            parms.Add("@BrandId", id);
            return await _dapperPro.GetAsync<BrandEntity>(sql, parms, commandType: CommandType.Text);
        }
    }
}
