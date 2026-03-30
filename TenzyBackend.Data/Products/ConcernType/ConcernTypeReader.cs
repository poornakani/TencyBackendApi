using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ConcernType
{
    public class ConcernTypeReader : ReaderBase<ConcernTypeEntity,int, ConcernTypeReader>,  IConcernTypeReader
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<ConcernTypeReader> _logger;

        public ConcernTypeReader(DapperMethods dapperPro,
           ILogger<ConcernTypeReader> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected override string GetByIdProcedureName => "sp_ConcernType_GetById";

        protected override string GetAllProcedureName => "sp_ConcernType_GetAll";

        protected override string IdParameterName => "@ConcernTypeId";
    }
}
