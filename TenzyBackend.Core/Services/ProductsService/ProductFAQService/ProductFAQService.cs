
using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.ProductFAQ;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ProductFAQService
{
    public class ProductFAQService : IProductFAQService
    {
        private readonly IProductFAQReader _productFAQReader;
        private readonly IProductFAQWriter _productFAQWriter;
        private readonly IObjectMapper _objectMapper;

        public ProductFAQService(IProductFAQReader productFAQReader, IProductFAQWriter productFAQWriter, IObjectMapper objectMapper)
        {
            _productFAQReader = productFAQReader;
            _productFAQWriter = productFAQWriter;
            _objectMapper = objectMapper;
        }
        public async Task<bool> ActiveProductFAQAsync(int productFAQId)
        {
            if (productFAQId <= 0)
                throw new NotFoundException("Invalid Payment Type ID");
            var entries =await  _productFAQWriter.ActiveAsync(productFAQId) ;
            return entries;
  
        }

        public async Task<int> CreateProductFAQAsync(ProductFAQModel productFAQModel)
        {
            if (productFAQModel == null) throw new NotFoundException("Empty Payment Type details");
            var productFAQEntity = _objectMapper.Map<ProductFAQModel, ProductFAQEntity>(productFAQModel);
            var insertResult = await _productFAQWriter.CreateAsync(productFAQEntity);

            return insertResult;
    
        }

        public async Task<bool> DeactiveProductFAQAsync(int productFAQId)
        {
            if (productFAQId <= 0)
                throw new NotFoundException("Invalid Payment Type ID");
            var entries = await _productFAQWriter.DeactiveAsync(productFAQId);
            return entries;
           
        }

        public async Task<List<ProductFAQModel>> GetAllProductFAQsAsync()
        {
            List<ProductFAQModel> paymentTypeModels = new List<ProductFAQModel>();
            var entries = await _productFAQReader.GetAllAsync();
            foreach (var entry in entries)
            {
                var mapobject = _objectMapper.Map<ProductFAQEntity, ProductFAQModel>(entry);
                paymentTypeModels.Add(mapobject);
            }
            return paymentTypeModels;

        }

        public async Task<ProductFAQModel?> GetProductFAQByIdAsync(int productFAQId)
        {
            if (productFAQId <= 0)
                throw new NotFoundException("Invalid Payment Type ID");
            var entries = await _productFAQReader.GetByIdAsync(productFAQId);
            var data =  _objectMapper.Map<ProductFAQEntity, ProductFAQModel>(entries);
            return data;

        }

        public async Task<bool> UpdateProductFAQAsync(ProductFAQModel productFAQModel)
        {
            if (productFAQModel == null) throw new NotFoundException("Empty Product FAQ details");
            var productFAQEntity = _objectMapper.Map<ProductFAQModel, ProductFAQEntity>(productFAQModel);
            var insertResult =await _productFAQWriter.UpdateAsync(productFAQEntity);

            return insertResult;
            
        }
    }
}
