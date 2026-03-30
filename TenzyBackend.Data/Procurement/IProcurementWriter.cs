using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.ProcurementModels;

namespace TenzyBackend.Data.Procurement
{
    public interface IProcurementWriter
    {
        Task<int> CreateOrderAsync(CreateProcurementOrderRequest request, Guid createdByUserId);
        Task<bool> UpdateStatusAsync(int orderId, string status, Guid? approvedByUserId = null);
    }
}
