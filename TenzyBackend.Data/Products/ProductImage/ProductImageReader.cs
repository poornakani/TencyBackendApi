using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductImage
{
    public class ProductImageReader : ReaderBase<ProductImageEntity, int, ProductImageReader>, IProductImageReader
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<ProductImageReader> _logger;
        public ProductImageReader(DapperMethods dapperPro,
           ILogger<ProductImageReader> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected override string GetByIdProcedureName => "sp_GetProductImageById";

        protected override string GetAllProcedureName => "sp_GetAllProductImage";

        protected override string IdParameterName => "@ImageId";
    }
}
