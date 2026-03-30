using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Data.Products.Brand;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Category
{
    public class CategoryWriter: WriterBase<CategoryEntity, int, CategoryWriter>, ICategoryWriter
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<CategoryWriter> _logger;

        public CategoryWriter(DapperMethods dapperPro,
           ILogger<CategoryWriter> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected override string CreateProcedureName => "sp_Category_Create";

        protected override string UpdateProcedureName => "sp_Category_Update";

        protected override string DeleteProcedureName => throw new NotImplementedException();

        protected override string DeactiveProcedureName => "sp_Category_Deactivate";

        protected override string ActiveProcedureName => "sp_Category_Activate";

        protected override string IdParameterName => "@CategoryId";

        protected override DynamicParameters BuildCreateParameters(CategoryEntity entity)
        {
            var parameters = new DynamicParameters();
            parameters.Add("@CategoryType", entity.CategoryType);
            return parameters;
        }

        protected override DynamicParameters BuildUpdateParameters(CategoryEntity entity)
        {
            var parameters = new DynamicParameters();
            parameters.Add("@CategoryId", entity.CategoryId);
            parameters.Add("@CategoryType", entity.CategoryType);
            return parameters;
        }
    }
}
