using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.Brand
{
    public class BrandWriter : WriterBase<BrandEntity, int, BrandWriter>, IBrandWriter
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<BrandWriter> _logger;

        public BrandWriter(
           DapperMethods dapperPro,
           ILogger<BrandWriter> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        //public BrandWriter(DapperMethods dapperPro, ILogger<BrandWriter> logger)
        //{
        //    _dapperPro=dapperPro;
        //    _logger=logger;
        //}


        protected override string CreateProcedureName => "sp_Brand_Insert";

        protected override string UpdateProcedureName => "sp_Brand_Update";

        protected override string DeleteProcedureName => "";

        protected override string IdParameterName => "@BrandId";

        protected override string DeactiveProcedureName => "sp_Brand_Deactivate";

        protected override string ActiveProcedureName => throw new NotImplementedException();

        protected override DynamicParameters BuildCreateParameters(BrandEntity entity)
        {
            var parameters = new DynamicParameters();
            parameters.Add("@Name", entity.Name);
            parameters.Add("@BrandImage", entity.BrandImage);
            return parameters;
        }

        protected override DynamicParameters BuildUpdateParameters(BrandEntity entity)
        {
            var parameters = new DynamicParameters();
            parameters.Add("@BrandId", entity.BrandId);
            parameters.Add("@Name", entity.Name);
            parameters.Add("@BrandImage", entity.BrandImage);
            return parameters;
        }
    }
}
