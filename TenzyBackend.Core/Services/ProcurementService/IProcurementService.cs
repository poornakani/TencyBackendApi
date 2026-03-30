using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.ProcurementModels;

namespace TenzyBackend.Core.Services.ProcurementService
{
    public interface IProcurementService
    {
        Task<List<ProcurementOrderModel>> GetAllOrdersAsync();
        Task<ProcurementOrderModel> GetOrderByIdAsync(int id);
        Task<int> CreateOrderAsync(CreateProcurementOrderRequest request, Guid createdByUserId);
        Task<bool> UpdateStatusAsync(int orderId, string status, Guid approvedByUserId);
    }
}
