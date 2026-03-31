using System;
using System.Threading.Tasks;
using TenzyBackend.Models.DispatchModels;

namespace TenzyBackend.Data.Dispatch
{
    public interface IDispatchWriter
    {
        Task<int> UpsertDispatchAsync(UpsertDispatchRequest request, Guid createdByUserId);
        Task<bool> MarkDeliveredAsync(int orderId);
    }
}
