using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Dispatch;
using TenzyBackend.Entity.DispatchEntity;
using TenzyBackend.Models.DispatchModels;

namespace TenzyBackend.Core.Services.DispatchService
{
    public class DispatchService : IDispatchService
    {
        private readonly IDispatchReader _reader;
        private readonly IDispatchWriter _writer;
        private readonly IObjectMapper _mapper;

        public DispatchService(IDispatchReader reader, IDispatchWriter writer, IObjectMapper mapper)
        {
            _reader = reader;
            _writer = writer;
            _mapper = mapper;
        }

        public async Task<List<DispatchModel>> GetPendingDispatchAsync()
        {
            var entities = await _reader.GetPendingAsync();
            return _mapper.Map<List<DispatchEntity>, List<DispatchModel>>(entities);
        }

        public async Task<int> UpsertDispatchAsync(UpsertDispatchRequest request, Guid adminUserId)
        {
            if (request.OrderId <= 0) throw new ValidationException("Invalid order id.");
            return await _writer.UpsertDispatchAsync(request, adminUserId);
        }

        public async Task<bool> MarkDeliveredAsync(int orderId)
        {
            if (orderId <= 0) throw new ValidationException("Invalid order id.");
            return await _writer.MarkDeliveredAsync(orderId);
        }
    }
}
