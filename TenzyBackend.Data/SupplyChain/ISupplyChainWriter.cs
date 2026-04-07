using System;
using System.Threading.Tasks;
using TenzyBackend.Models.SupplyChainModels;

namespace TenzyBackend.Data.SupplyChain
{
    public interface ISupplyChainWriter
    {
        Task<int> SaveProcurementAsync(SaveProcurementRequest request, string itemsJson, string discountsJson, string allocationsJson, Guid userId);
        Task<int> SaveDispatchAsync(SaveDispatchRequest request, string itemsJson, Guid userId);
        Task<int> AddShipmentChargeAsync(int shipmentId, AddShipmentChargeRequest request, Guid userId);
        Task<int> SaveArrivalAsync(SaveArrivalRequest request, string itemsJson, Guid userId);
        Task<int> SavePricingAsync(SavePricingRequest request, Guid userId);
        Task<int> ActivatePricingAsync(int pricingId, bool forceActivate, Guid userId);
        Task DeleteProcurementItemAsync(int procurementItemId, string? reason, Guid userId);
        Task UpdateProcurementItemAsync(int procurementItemId, UpdateProcurementItemRequest request);
        Task DeleteDispatchItemAsync(int shipmentItemId, string? reason, Guid userId);
        Task UpdateDispatchItemAsync(int shipmentItemId, UpdateDispatchItemRequest request);
    }
}
