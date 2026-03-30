using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.PaymentTypeService
{
    public interface IPaymentTypeService
    {
        Task<int> CreatePaymentTypeAsync(PaymentTypeModel paymentTypeModel);
        Task<bool> UpdatePaymentTypeAsync(PaymentTypeModel paymentTypeModel);
        Task<bool> DeactivePaymentTypeAsync(int paymentTypeId);
        Task<bool> ActivePaymentTypeAsync(int paymentTypeId);
        Task<PaymentTypeModel?> GetPaymentTypeByIdAsync(int paymentTypeId);
        Task<List<PaymentTypeModel>> GetAllPaymentTypesAsync();
    }
}
