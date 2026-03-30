using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Data.Products.ConcernType;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductFAQ
{
    public class ProductFAQWriter : WriterBase<ProductFAQEntity, int, ProductFAQWriter>, IProductFAQWriter
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<ProductFAQWriter> _logger;

        public ProductFAQWriter(DapperMethods dapperPro,
           ILogger<ProductFAQWriter> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }
        protected override string CreateProcedureName => "sp_CreateFAQ";

        protected override string UpdateProcedureName => "sp_UpdateFAQ";

        protected override string DeleteProcedureName => throw new NotImplementedException();

        protected override string DeactiveProcedureName => "sp_DeactiveFAQ";

        protected override string ActiveProcedureName => "sp_ActiveFAQ";

        protected override string IdParameterName => "@FAQId";

       

        protected override DynamicParameters BuildCreateParameters(ProductFAQEntity entity)
        {
            var dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@ProductId", entity.ProductId);
            dynamicParameters.Add("@Question", entity.Question);
            dynamicParameters.Add("@Answer", entity.Answer);
            return dynamicParameters;
        }

        protected override DynamicParameters BuildUpdateParameters(ProductFAQEntity entity)
        {
            var dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@FAQId", entity.FAQId);
            dynamicParameters.Add("@ProductId", entity.ProductId);
            dynamicParameters.Add("@Question", entity.Question);
            dynamicParameters.Add("@Answer", entity.Answer);    
            return dynamicParameters;
        }
    }
}
