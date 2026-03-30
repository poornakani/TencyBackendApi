using Microsoft.Extensions.Logging;
using SharedResources.Infrastructure.Base;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.PaymentType
{
    public class PaymentTypeReader : ReaderBase <PaymentTypeEntity, int, PaymentTypeReader>, IPaymentTypeReader
    {
        private readonly DapperMethods _dapperPro;
        private readonly ILogger<PaymentTypeReader> _logger;

        public PaymentTypeReader(DapperMethods dapperPro,
           ILogger<PaymentTypeReader> logger)
           : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected override string GetByIdProcedureName => "sp_GetPaymentTypeById";

        protected override string GetAllProcedureName => "sp_GetAllPaymentType";

        protected override string IdParameterName => "@PaymentTypeId";

        
    }
}
