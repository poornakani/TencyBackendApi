using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.DispatchModels;

namespace TenzyBackend.Core.Services.DispatchService
{
    public interface IDispatchService
    {
        Task<List<DispatchModel>> GetPendingDispatchAsync();
        Task<int> UpsertDispatchAsync(UpsertDispatchRequest request, Guid adminUserId);
        Task<bool> MarkDeliveredAsync(int orderId);
    }
}
