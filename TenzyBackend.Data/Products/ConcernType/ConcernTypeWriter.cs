using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Data.Products.Category;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ConcernType
{
    public class ConcernTypeWriter : WriterBase<ConcernTypeEntity, int, ConcernTypeWriter>, IConcernTypeWriter
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<ConcernTypeWriter> _logger;

        public ConcernTypeWriter(DapperMethods dapperPro,
           ILogger<ConcernTypeWriter> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected override string CreateProcedureName => "sp_ConcernType_Create";

        protected override string UpdateProcedureName => "sp_ConcernType_Update";

        protected override string DeleteProcedureName => throw new NotImplementedException();

        protected override string DeactiveProcedureName => "sp_ConcernType_Deactivate";

        protected override string ActiveProcedureName => "sp_ConcernType_Activate";

        protected override string IdParameterName => "@ConcernTypeId";

        protected override DynamicParameters BuildCreateParameters(ConcernTypeEntity entity)
        {
            var dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@ConcernType", entity.Name);
            dynamicParameters.Add("@Description", entity.Description);   
            return dynamicParameters;
        }

        protected override DynamicParameters BuildUpdateParameters(ConcernTypeEntity entity)
        {
            var dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@ConcernTypeId", entity.ConcernTypeId);  
            dynamicParameters.Add("@ConcernType", entity.Name);
            dynamicParameters.Add("@Description", entity.Description);
            return dynamicParameters;
        }
    }
}
