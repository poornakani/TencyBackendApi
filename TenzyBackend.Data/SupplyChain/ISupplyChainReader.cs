using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Models.SupplyChainModels;

namespace TenzyBackend.Data.SupplyChain
{
    public interface ISupplyChainReader
    {
        Task<SupplyChainDashboardModel> GetDashboardAsync();
        Task<List<SupplyProcurementListItemModel>> GetProcurementsAsync();
        Task<SupplyProcurementModel?> GetProcurementByIdAsync(int procurementId);
        Task<List<SupplyDispatchListItemModel>> GetDispatchesAsync();
        Task<SupplyDispatchModel?> GetDispatchByIdAsync(int shipmentId);
        Task<List<SupplyArrivalListItemModel>> GetArrivalsAsync();
        Task<SupplyArrivalModel?> GetArrivalByIdAsync(int arrivalVerificationId);
        Task<List<EligiblePricingItemModel>> GetEligiblePricingItemsAsync();
        Task<List<SupplyPricingModel>> GetPricingAsync();
        Task<List<SupplyProcurementReportRowModel>> GetProcurementReportAsync(DateTime? startDate, DateTime? endDate, string? shop, string? brand, string? product, string? category);
        Task<List<SupplyDispatchReportRowModel>> GetDispatchReportAsync(DateTime? startDate, DateTime? endDate, string? courier, string? brand, string? product, string? category, string? shipmentStatus);
        Task<List<SupplyMonthlyDispatchSummaryModel>> GetMonthlyDispatchSummaryAsync(DateTime? startDate, DateTime? endDate);
        Task<List<DeletedItemLogModel>> GetDeletedItemsAsync(string? tableName);
    }
}
