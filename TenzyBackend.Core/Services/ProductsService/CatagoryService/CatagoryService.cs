using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.Category;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.CatagoryService
{
    public class CatagoryService : ICatagoryService
    {
        private readonly ICategoryReader _catagoryReader;
        private readonly ICategoryWriter _catagoryWriter;
        private readonly IObjectMapper _objectMapper;
        public CatagoryService(ICategoryReader catagoryReader, ICategoryWriter catagoryWriter, IObjectMapper objectMapper)
        {
            _catagoryReader = catagoryReader;
            _catagoryWriter = catagoryWriter;
            _objectMapper = objectMapper;
        }
        public async Task<bool> ActiveCatagoryAsync(int catagoryId)
        {
            if (catagoryId <= 0)
                throw new NotFoundException("Invalid catagory ID");
            var result = await _catagoryWriter.ActiveAsync(catagoryId);
            return result;
        }

        public async Task<int> CreateCatagoryAsync(CatagoryModel catagoryModel)
        {
            if (catagoryModel == null)
                throw new NotFoundException("Empty catagory details");

            var catagoryEntity = _objectMapper.Map<CatagoryModel, CategoryEntity>(catagoryModel);

            var insertResult = await _catagoryWriter.CreateAsync(catagoryEntity);
            return insertResult;

        }

        public async Task<bool> DeactiveCatagoryAsync(int catagoryId)
        {
            if (catagoryId <= 0)
                throw new NotFoundException("Invalid catagory ID");
            var result = await _catagoryWriter.DeactiveAsync(catagoryId);
            return result;
        }

        public async Task<List<CatagoryModel>> GetAllCatagoriesAsync()
        {
            List<CatagoryModel> catagoryModelsList = new List<CatagoryModel>();
            var catagoryEntity = await _catagoryReader.GetAllAsync();
            foreach (var single in catagoryEntity) 
            {
                var catagoryModel =  _objectMapper.Map<CategoryEntity, CatagoryModel>(single);
                catagoryModelsList.Add(catagoryModel);
            }

            return catagoryModelsList;
            
        }

        public async Task<CatagoryModel?> GetCatagoryByIdAsync(int catagoryId)
        {
            if (catagoryId <= 0)
                throw new NotFoundException("Invalid catagory ID");

            var catagoryEntity = await _catagoryReader.GetByIdAsync(catagoryId);
            if (catagoryEntity == null)
                return null;

            var catagoryModel = _objectMapper.Map<CategoryEntity, CatagoryModel>(catagoryEntity);
            return catagoryModel;
        }

        public Task<bool> UpdateCatagoryAsync(CatagoryModel catagoryModel)
        {
            // object mapping
            var cateoryEntity = _objectMapper.Map<CatagoryModel, CategoryEntity>(catagoryModel);

            var result = _catagoryWriter.UpdateAsync(cateoryEntity);
            return result;
      
        }

    }
}
