using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.OrderModels;

namespace TenzyBackend.Core.Services.OrderService
{
    public interface IOrderService
    {
        Task<List<OrderModel>> GetAllOrdersAsync(int page, int pageSize, string? status, Guid? userId);
        Task<OrderModel> GetOrderByIdAsync(int id);
        Task<List<OrderModel>> GetUserOrdersAsync(Guid userId, int page, int pageSize);
        Task<int> CreateOrderAsync(CreateOrderRequest request);
        Task<bool> UpdateOrderStatusAsync(int orderId, string status);
    }
}
