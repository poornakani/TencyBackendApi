using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Brand
{
    public class BrandReader : ReaderBase<BrandEntity, int, BrandReader>, IBrandReader
    {
        public BrandReader( DapperMethods dapperMethods,ILogger<BrandReader> logger)
            : base(dapperMethods, logger)
        {
        }

        protected override string GetByIdProcedureName => "sp_Brand_GetById";

        protected override string GetAllProcedureName => "sp_Brand_GetAll";

        protected override string IdParameterName => "@BrandId";
    }
}
