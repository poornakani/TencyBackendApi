using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.PaymentType
{
    public class PaymentTypeWriter : WriterBase<PaymentTypeEntity, int, PaymentTypeWriter>, IPaymentTypeWriter
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<PaymentTypeWriter> _logger;

        public PaymentTypeWriter(DapperMethods dapperPro,
           ILogger<PaymentTypeWriter> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected override string CreateProcedureName => "sp_CreatePaymentType";

        protected override string UpdateProcedureName => "sp_UpdatePaymentType";

        protected override string DeleteProcedureName => throw new NotImplementedException(); 

        protected override string DeactiveProcedureName => "sp_DeactivePaymentType";

        protected override string ActiveProcedureName => "sp_ActivePaymentType";

        protected override string IdParameterName => "@PaymentTypeId";

        protected override DynamicParameters BuildCreateParameters(PaymentTypeEntity entity)
        {
            var dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@PaymentType", entity.Name);
            return dynamicParameters;
           
        }

        protected override DynamicParameters BuildUpdateParameters(PaymentTypeEntity entity)
        {
            var dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@PaymentTypeId", entity.PaymentTypeId);
            dynamicParameters.Add("@PaymentType", entity.Name);
            return dynamicParameters;
        }
    }
}
