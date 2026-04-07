using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.SupplyChainModels;

namespace TenzyBackend.Core.Services.SupplyChainService
{
    public interface ISupplyChainService
    {
        Task<SupplyChainDashboardModel> GetDashboardAsync();
        Task<List<SupplyProcurementListItemModel>> GetProcurementsAsync();
        Task<SupplyProcurementModel> GetProcurementByIdAsync(int procurementId);
        Task<int> SaveProcurementAsync(SaveProcurementRequest request, Guid userId);
        Task<List<SupplyDispatchListItemModel>> GetDispatchesAsync();
        Task<SupplyDispatchModel> GetDispatchByIdAsync(int shipmentId);
        Task<int> SaveDispatchAsync(SaveDispatchRequest request, Guid userId);
        Task<int> AddShipmentChargeAsync(int shipmentId, AddShipmentChargeRequest request, Guid userId);
        Task<List<SupplyArrivalListItemModel>> GetArrivalsAsync();
        Task<SupplyArrivalModel> GetArrivalByIdAsync(int arrivalVerificationId);
        Task<int> SaveArrivalAsync(SaveArrivalRequest request, Guid userId);
        Task<List<EligiblePricingItemModel>> GetEligiblePricingItemsAsync();
        Task<List<SupplyPricingModel>> GetPricingAsync();
        Task<int> SavePricingAsync(SavePricingRequest request, Guid userId);
        Task<int> ActivatePricingAsync(int pricingId, bool forceActivate, Guid userId);
        Task<List<SupplyProcurementReportRowModel>> GetProcurementReportAsync(DateTime? startDate, DateTime? endDate, string? shop, string? brand, string? product, string? category);
        Task<List<SupplyDispatchReportRowModel>> GetDispatchReportAsync(DateTime? startDate, DateTime? endDate, string? courier, string? brand, string? product, string? category, string? shipmentStatus);
        Task<List<SupplyMonthlyDispatchSummaryModel>> GetMonthlyDispatchSummaryAsync(DateTime? startDate, DateTime? endDate);
        Task DeleteProcurementItemAsync(int procurementItemId, string? reason, Guid userId);
        Task UpdateProcurementItemAsync(int procurementItemId, UpdateProcurementItemRequest request);
        Task DeleteDispatchItemAsync(int shipmentItemId, string? reason, Guid userId);
        Task UpdateDispatchItemAsync(int shipmentItemId, UpdateDispatchItemRequest request);
        Task<List<DeletedItemLogModel>> GetDeletedItemsAsync(string? tableName);
    }
}
