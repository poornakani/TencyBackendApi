using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Orders;
using TenzyBackend.Entity.OrderEntity;
using TenzyBackend.Models.OrderModels;

namespace TenzyBackend.Core.Services.OrderService
{
    public class OrderService : IOrderService
    {
        private readonly IOrderReader _reader;
        private readonly IOrderWriter _writer;
        private readonly IObjectMapper _mapper;

        private static readonly string[] ValidStatuses =
            { "pending", "processing", "dispatched", "delivered", "cancelled" };

        public OrderService(IOrderReader reader, IOrderWriter writer, IObjectMapper mapper)
        {
            _reader = reader;
            _writer = writer;
            _mapper = mapper;
        }

        public async Task<List<OrderModel>> GetAllOrdersAsync(int page, int pageSize, string? status, Guid? userId)
        {
            if (page < 1) page = 1;
            if (pageSize is < 1 or > 100) pageSize = 20;
            int offset = (page - 1) * pageSize;

            var entities = await _reader.GetAllAsync(pageSize, offset, status, userId);
            return _mapper.Map<List<OrderEntity>, List<OrderModel>>(entities);
        }

        public async Task<OrderModel> GetOrderByIdAsync(int id)
        {
            if (id <= 0) throw new ValidationException("Invalid order id.");

            var entity = await _reader.GetByIdAsync(id)
                ?? throw new NotFoundException("Order not found.");

            var model = _mapper.Map<OrderEntity, OrderModel>(entity);
            model.Items = _mapper.Map<List<OrderItemEntity>, List<OrderItemModel>>(entity.Items);
            return model;
        }

        public async Task<List<OrderModel>> GetUserOrdersAsync(Guid userId, int page, int pageSize)
        {
            if (page < 1) page = 1;
            if (pageSize is < 1 or > 50) pageSize = 20;
            int offset = (page - 1) * pageSize;

            var entities = await _reader.GetByUserIdAsync(userId, pageSize, offset);
            return _mapper.Map<List<OrderEntity>, List<OrderModel>>(entities);
        }

        public async Task<int> CreateOrderAsync(CreateOrderRequest request)
        {
            if (request.UserId == Guid.Empty)
                throw new ValidationException("UserId is required.");
            if (string.IsNullOrWhiteSpace(request.PaymentMethod))
                throw new ValidationException("Payment method is required.");
            if (string.IsNullOrWhiteSpace(request.ShippingName))
                throw new ValidationException("Shipping name is required.");
            if (string.IsNullOrWhiteSpace(request.ShippingPhone))
                throw new ValidationException("Shipping phone is required.");
            if (string.IsNullOrWhiteSpace(request.ShippingAddress))
                throw new ValidationException("Shipping address is required.");
            if (string.IsNullOrWhiteSpace(request.ShippingCity))
                throw new ValidationException("Shipping city is required.");
            if (!request.Items.Any())
                throw new ValidationException("At least one item is required.");
            if (request.TotalLkr <= 0)
                throw new ValidationException("Order total must be greater than zero.");

            return await _writer.CreateOrderAsync(request);
        }

        public async Task<bool> UpdateOrderStatusAsync(int orderId, string status)
        {
            if (!ValidStatuses.Contains(status))
                throw new ValidationException(
                    $"Invalid status '{status}'. Must be one of: {string.Join(", ", ValidStatuses)}");

            var existing = await _reader.GetByIdAsync(orderId)
                ?? throw new NotFoundException("Order not found.");

            if (existing.Status == "cancelled" && status != "cancelled")
                throw new ValidationException("Cannot change status of a cancelled order.");

            return await _writer.UpdateStatusAsync(orderId, status);
        }
    }
}
