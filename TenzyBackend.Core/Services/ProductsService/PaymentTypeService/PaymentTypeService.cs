using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Core.Mapping;
using SharedResources.Exceptions;
using TenzyBackend.Data.Products.PaymentType;
using TenzyBackend.Models.ProductsModels;
using TenzyBackend.Entity.ProductsEntity;
using System.ComponentModel.DataAnnotations;

namespace TenzyBackend.Core.Services.ProductsService.PaymentTypeService
{
    public class PaymentTypeService : IPaymentTypeService
    {
        private readonly IPaymentTypeReader _paymentTypeReader;
        private readonly IPaymentTypeWriter _paymentTypeWriter;
        private readonly IObjectMapper _objectMapper;
        public PaymentTypeService(IPaymentTypeReader paymentTypeReader, IPaymentTypeWriter paymentTypeWriter, IObjectMapper objectMapper) 
        {
            _paymentTypeReader= paymentTypeReader;
            _paymentTypeWriter= paymentTypeWriter;
            _objectMapper= objectMapper;
        }

        public async Task<bool> ActivePaymentTypeAsync(int paymentTypeId)
        {
            if (paymentTypeId <= 0)
                 throw new NotFoundException("Invalid Payment Type ID");
            var result = await _paymentTypeWriter.ActiveAsync(paymentTypeId);
            return result;
        }

        public Task<int> CreatePaymentTypeAsync(PaymentTypeModel paymentTypeModel)
        {
            if (paymentTypeModel == null) throw new NotFoundException("Empty Payment Type details");
             var paymentTypeEntity = _objectMapper.Map<PaymentTypeModel, PaymentTypeEntity>(paymentTypeModel);
             var insertResult = _paymentTypeWriter.CreateAsync(paymentTypeEntity);
             return insertResult;
        
        }

        public async Task<bool> DeactivePaymentTypeAsync(int paymentTypeId)
        {
            if (paymentTypeId <= 0)
                throw new NotFoundException("Invalid Payment Type ID");
            var result = await _paymentTypeWriter.DeactiveAsync(paymentTypeId);
            return result;
        }

        public async Task<List<PaymentTypeModel>> GetAllPaymentTypesAsync()
        {
            List<PaymentTypeModel> paymentTypeModels = new List<PaymentTypeModel>();
            var entries = await _paymentTypeReader.GetAllAsync();
            foreach (var entry in entries ) 
            {
                var mapobject = _objectMapper.Map<PaymentTypeEntity, PaymentTypeModel>(entry);
                paymentTypeModels.Add(mapobject);
            }
            return paymentTypeModels;
        }

        public async Task<PaymentTypeModel?> GetPaymentTypeByIdAsync(int paymentTypeId)
        {
            if (paymentTypeId <= 0)
                throw new NotFoundException("Invalid Payment Type ID");
            var entries = await _paymentTypeReader.GetByIdAsync(paymentTypeId);
            var data = _objectMapper.Map<PaymentTypeEntity, PaymentTypeModel>(entries);
            return data;
   
        }

        public Task<bool> UpdatePaymentTypeAsync(PaymentTypeModel paymentTypeModel)
        {
            if (paymentTypeModel == null) throw new NotFoundException("Empty Payment Type details");
            var paymentTypeEntity = _objectMapper.Map<PaymentTypeModel, PaymentTypeEntity>(paymentTypeModel);
            var updateResult = _paymentTypeWriter.UpdateAsync(paymentTypeEntity);
            return updateResult;
        }
    }
}
