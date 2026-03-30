using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ProductCatalog
{
    public class ProductCatalogReader : ReaderBase<ProductCatalogEntity, int, ProductCatalogReader>,
                                        IProductCatalogReader
    {
        public ProductCatalogReader(DapperMethods dapperMethods, ILogger<ProductCatalogReader> logger)
            : base(dapperMethods, logger) { }

        protected override string GetByIdProcedureName => "spProductCatalog_GetById";
        protected override string GetAllProcedureName  => "spProductCatalog_GetAll";
        protected override string IdParameterName      => "@ProductId";
    }
}
