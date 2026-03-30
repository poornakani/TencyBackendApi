using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Procurement;
using TenzyBackend.Entity.ProcurementEntity;
using TenzyBackend.Models.ProcurementModels;

namespace TenzyBackend.Core.Services.ProcurementService
{
    public class ProcurementService : IProcurementService
    {
        private readonly IProcurementReader _reader;
        private readonly IProcurementWriter _writer;
        private readonly IObjectMapper _mapper;

        public ProcurementService(IProcurementReader reader, IProcurementWriter writer, IObjectMapper mapper)
        {
            _reader = reader;
            _writer = writer;
            _mapper = mapper;
        }

        public async Task<List<ProcurementOrderModel>> GetAllOrdersAsync()
        {
            var entities = await _reader.GetAllAsync();
            return _mapper.Map<List<ProcurementOrderEntity>, List<ProcurementOrderModel>>(entities);
        }

        public async Task<ProcurementOrderModel> GetOrderByIdAsync(int id)
        {
            if (id <= 0) throw new ValidationException("Invalid order id.");

            var entity = await _reader.GetByIdAsync(id)
                ?? throw new NotFoundException("Procurement order not found.");

            var model = _mapper.Map<ProcurementOrderEntity, ProcurementOrderModel>(entity);
            model.Items = _mapper.Map<List<ProcurementItemEntity>, List<ProcurementItemModel>>(entity.Items);
            return model;
        }

        public async Task<int> CreateOrderAsync(CreateProcurementOrderRequest request, Guid createdByUserId)
        {
            if (string.IsNullOrWhiteSpace(request.OrderReference))
                throw new ValidationException("Order reference is required.");
            if (string.IsNullOrWhiteSpace(request.SupplierName))
                throw new ValidationException("Supplier name is required.");
            if (request.GbpToLkr <= 0)
                throw new ValidationException("GBP to LKR rate must be greater than zero.");
            if (!request.Items.Any())
                throw new ValidationException("At least one item is required.");

            foreach (var item in request.Items)
            {
                if (item.Quantity <= 0)
                    throw new ValidationException($"Quantity for '{item.ProductName}' must be greater than zero.");
                if (item.UnitPriceGbp <= 0)
                    throw new ValidationException($"Unit price for '{item.ProductName}' must be greater than zero.");
            }

            return await _writer.CreateOrderAsync(request, createdByUserId);
        }

        public async Task<bool> UpdateStatusAsync(int orderId, string status, Guid approvedByUserId)
        {
            var validStatuses = new[] { "ordered", "in_transit", "arrived", "approved" };
            if (!validStatuses.Contains(status))
                throw new ValidationException($"Invalid status '{status}'. Must be one of: {string.Join(", ", validStatuses)}");

            var existing = await _reader.GetByIdAsync(orderId)
                ?? throw new NotFoundException("Procurement order not found.");

            // Status progression guard: can't go backwards
            var order = Array.IndexOf(validStatuses, existing.Status);
            var next  = Array.IndexOf(validStatuses, status);
            if (next < order)
                throw new ValidationException($"Cannot change status from '{existing.Status}' to '{status}'.");

            Guid? approver = status == "approved" ? approvedByUserId : null;
            return await _writer.UpdateStatusAsync(orderId, status, approver);
        }
    }
}
