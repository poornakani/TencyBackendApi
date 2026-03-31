using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Entity.OrderEntity;

namespace TenzyBackend.Data.Orders
{
    public interface IOrderReader
    {
        Task<List<OrderEntity>> GetAllAsync(int pageSize, int offset, string? status, Guid? userId);
        Task<OrderEntity?> GetByIdAsync(int id);
        Task<List<OrderEntity>> GetByUserIdAsync(Guid userId, int pageSize, int offset);
    }
}
