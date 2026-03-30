using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.ConcernType;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ConcernService
{
    public class ConcernService : IConcernService
    {
        private readonly IConcernTypeReader _concernReader;
        private readonly IConcernTypeWriter _concernWriter;
        private readonly IObjectMapper _objectMapper;

        public ConcernService(IConcernTypeReader concernReader, IConcernTypeWriter concernWriter, IObjectMapper objectMapper)
        {
            _concernReader = concernReader ?? throw new NotFoundException(nameof(concernReader));
            _concernWriter = concernWriter ?? throw new NotFoundException(nameof(concernWriter));
            _objectMapper = objectMapper ?? throw new NotFoundException(nameof(objectMapper));
        }

        public async Task<bool> ActiveConcernAsync(int concernId)
        {
            if (concernId <= 0) return false;
            var affected = await _concernWriter.ActiveAsync(concernId);
            return affected;
        }

        public async Task<int> CreateConcernAsync(ConcernTypeModel concernModel)
        {
            if (concernModel == null) throw new NotFoundException(nameof(concernModel));
            var entity = _objectMapper.Map<ConcernTypeModel,ConcernTypeEntity>(concernModel);
            var newId = await _concernWriter.CreateAsync(entity);
            return newId;
        }

        public async Task<bool> DeactiveConcernAsync(int concernId)
        {
            if (concernId <= 0) return false;
            var affected = await _concernWriter.DeactiveAsync(concernId);
            return affected ;
        }

        public async Task<List<ConcernTypeModel>> GetAllConcernsAsync()
        {
            List<ConcernTypeModel> result = new List<ConcernTypeModel>();

            var entities = await _concernReader.GetAllAsync();
            if (entities == null) return result;
            foreach (var entity in entities) 
            {
                var data = _objectMapper.Map<ConcernTypeEntity,ConcernTypeModel>(entity);
                result.Add(data);
            }

            return result;
        }

        public async Task<ConcernTypeModel?> GetConcernByIdAsync(int concernId)
        {
            if (concernId <= 0) return null;
            var entity = await _concernReader.GetByIdAsync(concernId);
            return entity == null ? null : _objectMapper.Map<ConcernTypeEntity,ConcernTypeModel>(entity);
        }

        public async Task<bool> UpdateConcernAsync(ConcernTypeModel concernModel)
        {
            if (concernModel == null) throw new NotFoundException(nameof(concernModel));
            var entity = _objectMapper.Map<ConcernTypeModel,ConcernTypeEntity>(concernModel);
            var affected = await _concernWriter.UpdateAsync(entity);
            return affected;
        }
    }
}
