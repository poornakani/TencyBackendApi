using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.ProductImage;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ProductImagesService
{
    public class ProductImageService : IProductImageService
    {
        private readonly IProductImageReader _productImageReader;
        private readonly IProductImageWriter _productImageWriter;
        private readonly IObjectMapper _objectMapper;
        public ProductImageService(IProductImageReader productImageReader, IProductImageWriter productImageWriter, IObjectMapper objectMapper)
        {
            _productImageReader= productImageReader;
            _productImageWriter= productImageWriter;
            _objectMapper= objectMapper;
        }
        public async Task<bool> ActiveProductImageAsync(int productImageId)
        {
            if (productImageId <= 0)
                throw new NotFoundException("Invalid Product image ID");
            var entries = await _productImageWriter.ActiveAsync(productImageId);
            return entries;
           
        }

        public async Task<int> CreateProductImageAsync(ProductImageModel productImageModel)
        {
            if (productImageModel == null) throw new NotFoundException("Empty Product image details");

            var productFAQEntity = _objectMapper.Map<ProductImageModel, ProductImageEntity>(productImageModel);

            var insertResult = await _productImageWriter.CreateAsync(productFAQEntity);

            return insertResult;
         
        }

        public async Task<bool> DeactiveProductImageAsync(int productImageId)
        {
            if (productImageId <= 0)
                throw new NotFoundException("Invalid Product image ID");
            var entries = await _productImageWriter.DeactiveAsync(productImageId);
            return entries;
            throw new NotImplementedException();
        }

        public async Task<List<ProductImageModel>> GetAllProductImagesAsync()
        {

            List<ProductImageModel> productImageModels = new List<ProductImageModel>();
            var entries = await _productImageReader.GetAllAsync();
            foreach (var entry in entries)
            {
                var mapobject = _objectMapper.Map<ProductImageEntity, ProductImageModel>(entry);
                productImageModels.Add(mapobject);
            }
            return productImageModels;
     
        }

        public async Task<ProductImageModel?> GetProductImageByIdAsync(int productImageId)
        {
            if (productImageId <= 0)
                throw new NotFoundException("Invalid product image ID");
            var entries = await _productImageReader.GetByIdAsync(productImageId);
            var data = _objectMapper.Map<ProductImageEntity, ProductImageModel>(entries);
            return data;
        
        }

        public async Task<bool> UpdateProductImageAsync(ProductImageModel productImageModel)
        {
            if (productImageModel == null) throw new NotFoundException("Empty produuct image details");
            var productFAQEntity = _objectMapper.Map<ProductImageModel, ProductImageEntity>(productImageModel);
            var insertResult = await _productImageWriter.UpdateAsync(productFAQEntity);

            return insertResult;

        }
    }
}
