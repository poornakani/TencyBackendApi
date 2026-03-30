using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductFAQ
{
    public class ProductFAQReader : ReaderBase<ProductFAQEntity, int, ProductFAQReader>, IProductFAQReader
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<ProductFAQReader> _logger;
        public ProductFAQReader(DapperMethods dapperPro,
           ILogger<ProductFAQReader> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }
        protected override string GetByIdProcedureName => "sp_GetFAQById";

        protected override string GetAllProcedureName => "sp_GetAllFAQ";

        protected override string IdParameterName => "@FAQId";
    }
}
