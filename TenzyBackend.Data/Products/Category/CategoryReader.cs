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
    public class CategoryReader : ReaderBase<CategoryEntity, int, CategoryReader>, ICategoryReader
    {
        public CategoryReader(DapperMethods dapperMethods, ILogger<CategoryReader> logger)
           : base(dapperMethods, logger)
        {
        }

        protected override string GetByIdProcedureName => "sp_Category_GetById";

        protected override string GetAllProcedureName => "sp_Category_GetAllActive";

        protected override string IdParameterName => "@CategoryId";
    }
}
