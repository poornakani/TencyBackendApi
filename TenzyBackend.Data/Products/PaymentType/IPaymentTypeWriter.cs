using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.PaymentType
{
    public interface IPaymentTypeWriter
    {
        Task<int> CreateAsync(PaymentTypeEntity paymenttypeEntity);
        Task<bool> UpdateAsync(PaymentTypeEntity paymenttypeEntity);
        Task<bool> DeactiveAsync(int concernID);
        Task<bool> ActiveAsync(int concernID);
    }
}
