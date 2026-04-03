using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.Brand;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.BrandService
{
    public class BrandService : IBrandService
    {
        private readonly IBrandReader _brandReader;
        private readonly IBrandWriter _brandWriter;
        private readonly IObjectMapper _objectMapper;
        public BrandService(IBrandReader brandReader, IBrandWriter brandWriter, IObjectMapper objectMapper)
        {
            _brandReader=brandReader;
            _brandWriter =brandWriter;
            _objectMapper=objectMapper;
        }

        public Task<int> CreateBrandAsync(BrandModel requestbrandModel)
        {
            ValidateBrand(requestbrandModel, requireId: false);
            var covertEntity = _objectMapper.Map<BrandModel,BrandEntity>(requestbrandModel);
            return _brandWriter.CreateAsync(covertEntity);
        }

        public async Task<bool> UpdateBrandAsync(BrandModel requestbrandModel)
        {
            ValidateBrand(requestbrandModel, requireId: true);
            var covertEntity= _objectMapper.Map<BrandModel, BrandEntity>(requestbrandModel);

            var existingBrand = await _brandReader.GetByIdAsync(requestbrandModel.BrandId);
            if (existingBrand == null)
                throw new NotFoundException("Brand not found.");

            return await _brandWriter.UpdateAsync(covertEntity);
        }

        public async Task<bool> DeactiveBrandAsync(int brandId)
        {
            if (brandId <= 0)
                throw new ValidationException("Invalid brand id.");

            var existingBrand = await _brandReader.GetByIdAsync(brandId);
            if (existingBrand == null)
                throw new NotFoundException("Brand not found.");

            return await _brandWriter.DeleteAsync(brandId);
        }

        public async Task<BrandModel?> GetBrandByIdAsync(int brandId)
        {
            if (brandId <= 0)
                throw new ValidationException("Invalid brand id.");

            var brand = await _brandReader.GetByIdAsync(brandId);
            if (brand == null)
                throw new NotFoundException("Brand not found.");

            var covertModel = _objectMapper.Map<BrandEntity,BrandModel>(brand);
            return covertModel;
        }

        public async Task<List<BrandModel>> GetAllBrandsAsync()
        {
            var listofBards = await _brandReader.GetAllAsync();
            var covertModelList = _objectMapper.Map<List<BrandEntity>, List<BrandModel>>(listofBards); 
            return covertModelList;
            
        }


        private static void ValidateBrand(BrandModel brandEntity, bool requireId)
        {
            var errors = new Dictionary<string, string[]>();

            if (brandEntity == null)
            {
                errors["Brand"] = new[] { "Brand data is required." };
            }
            else
            {
                if (requireId && brandEntity.BrandId <= 0)
                    errors["BrandId"] = new[] { "Valid brand id is required." };

                if (string.IsNullOrWhiteSpace(brandEntity.Name))
                    errors["Name"] = new[] { "Brand name is required." };

                if (brandEntity.Name?.Length > 200)
                    errors["Name"] = new[] { "Brand name cannot exceed 200 characters." };

                if (!string.IsNullOrWhiteSpace(brandEntity.BrandImage) && brandEntity.BrandImage.Length > 500)
                    errors["BrandImage"] = new[] { "Brand image cannot exceed 500 characters." };
            }

            if (errors.Any())
                throw new ValidationException("Validation failed.", errors);
        }


        
    }
}
