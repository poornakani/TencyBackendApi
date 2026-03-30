using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.PaymentType
{
    public interface IPaymentTypeReader
    {
        Task<PaymentTypeEntity?> GetByIdAsync(int paytypeId);
        Task<List<PaymentTypeEntity>> GetAllAsync();
    }
}
