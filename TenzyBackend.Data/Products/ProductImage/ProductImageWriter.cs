using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Data.Products.ProductFAQ;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductImage
{
    public class ProductImageWriter : WriterBase<ProductImageEntity, int, ProductImageWriter>, IProductImageWriter
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<ProductImageWriter> _logger;

        public ProductImageWriter(DapperMethods dapperPro,
           ILogger<ProductImageWriter> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected override string CreateProcedureName => "sp_CreateProductImage";

        protected override string UpdateProcedureName => "sp_UpdateProductImage";

        protected override string DeleteProcedureName => throw new NotImplementedException();

        protected override string DeactiveProcedureName => "sp_DeactiveProductImage";

        protected override string ActiveProcedureName => "sp_ActiveProductImage";

        protected override string IdParameterName => "@ImageId";

        protected override DynamicParameters BuildCreateParameters(ProductImageEntity entity)
        {
            var parameters = new DynamicParameters();
            parameters.Add("@ProductId", entity.ProductId);
            parameters.Add("@ImageUrl", entity.ImageUrl);
            parameters.Add("@IsPrimary", entity.IsPrimary);
            parameters.Add("@SortOrder", entity.SortOrder);
            return parameters;

        }

        protected override DynamicParameters BuildUpdateParameters(ProductImageEntity entity)
        {
            var parameters = new DynamicParameters();
            parameters.Add("@ImageId", entity.ImageId);
            parameters.Add("@ProductId", entity.ProductId);
            parameters.Add("@ImageUrl", entity.ImageUrl);
            parameters.Add("@IsPrimary", entity.IsPrimary);
            parameters.Add("@SortOrder", entity.SortOrder);
            parameters.Add("@IsActive", entity.IsActive);
            return parameters;
        }
    }
}
