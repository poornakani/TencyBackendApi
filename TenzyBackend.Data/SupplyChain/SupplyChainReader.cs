using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.SupplyChainModels;

namespace TenzyBackend.Data.SupplyChain
{
    public class SupplyChainReader : ISupplyChainReader
    {
        private readonly DapperMethods _dapper;

        public SupplyChainReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<SupplyChainDashboardModel> GetDashboardAsync()
        {
            return await _dapper.GetAsync<SupplyChainDashboardModel>(
                "spSupplyDashboard_GetSummary",
                new DynamicParameters(),
                CommandType.StoredProcedure) ?? new SupplyChainDashboardModel();
        }

        public async Task<List<SupplyProcurementListItemModel>> GetProcurementsAsync()
        {
            return await _dapper.GetAllAsync<SupplyProcurementListItemModel>(
                "spSupplyProcurement_GetAll",
                commandType: CommandType.StoredProcedure);
        }

        public async Task<SupplyProcurementModel?> GetProcurementByIdAsync(int procurementId)
        {
            using var db = _dapper._context.CreateConnection();
            if (db.State == ConnectionState.Closed) db.Open();

            var p = new DynamicParameters();
            p.Add("@ProcurementId", procurementId, DbType.Int32);

            using var multi = await db.QueryMultipleAsync("spSupplyProcurement_GetById", p, commandType: CommandType.StoredProcedure);
            var header = (await multi.ReadAsync<SupplyProcurementModel>()).FirstOrDefault();
            if (header == null) return null;

            header.Items = (await multi.ReadAsync<SupplyProcurementItemModel>()).ToList();
            header.Discounts = (await multi.ReadAsync<SupplyDiscountModel>()).ToList();
            var allocations = (await multi.ReadAsync<SupplyDiscountAllocationModel>()).ToList();

            foreach (var discount in header.Discounts)
            {
                discount.Allocations = allocations
                    .Where(a => a.DiscountId == discount.DiscountId)
                    .ToList();
            }

            return header;
        }

        public async Task<List<SupplyDispatchListItemModel>> GetDispatchesAsync()
        {
            return await _dapper.GetAllAsync<SupplyDispatchListItemModel>(
                "spSupplyDispatch_GetAll",
                commandType: CommandType.StoredProcedure);
        }

        public async Task<SupplyDispatchModel?> GetDispatchByIdAsync(int shipmentId)
        {
            using var db = _dapper._context.CreateConnection();
            if (db.State == ConnectionState.Closed) db.Open();

            var p = new DynamicParameters();
            p.Add("@ShipmentId", shipmentId, DbType.Int32);

            using var multi = await db.QueryMultipleAsync("spSupplyDispatch_GetById", p, commandType: CommandType.StoredProcedure);
            var header = (await multi.ReadAsync<SupplyDispatchModel>()).FirstOrDefault();
            if (header == null) return null;

            header.Items = (await multi.ReadAsync<SupplyDispatchItemModel>()).ToList();
            header.Charges = (await multi.ReadAsync<SupplyShipmentChargeModel>()).ToList();
            return header;
        }

        public async Task<List<SupplyArrivalListItemModel>> GetArrivalsAsync()
        {
            return await _dapper.GetAllAsync<SupplyArrivalListItemModel>(
                "spSupplyArrival_GetAll",
                commandType: CommandType.StoredProcedure);
        }

        public async Task<SupplyArrivalModel?> GetArrivalByIdAsync(int arrivalVerificationId)
        {
            using var db = _dapper._context.CreateConnection();
            if (db.State == ConnectionState.Closed) db.Open();

            var p = new DynamicParameters();
            p.Add("@ArrivalVerificationId", arrivalVerificationId, DbType.Int32);

            using var multi = await db.QueryMultipleAsync("spSupplyArrival_GetById", p, commandType: CommandType.StoredProcedure);
            var header = (await multi.ReadAsync<SupplyArrivalModel>()).FirstOrDefault();
            if (header == null) return null;

            header.Items = (await multi.ReadAsync<SupplyArrivalItemModel>()).ToList();
            return header;
        }

        public async Task<List<EligiblePricingItemModel>> GetEligiblePricingItemsAsync()
        {
            return await _dapper.GetAllAsync<EligiblePricingItemModel>(
                "spSupplyPricing_GetEligible",
                commandType: CommandType.StoredProcedure);
        }

        public async Task<List<SupplyPricingModel>> GetPricingAsync()
        {
            return await _dapper.GetAllAsync<SupplyPricingModel>(
                "spSupplyPricing_GetAll",
                commandType: CommandType.StoredProcedure);
        }

        public async Task<List<SupplyProcurementReportRowModel>> GetProcurementReportAsync(DateTime? startDate, DateTime? endDate, string? shop, string? brand, string? product, string? category)
        {
            var p = new DynamicParameters();
            p.Add("@StartDate", startDate, DbType.DateTime2);
            p.Add("@EndDate", endDate, DbType.DateTime2);
            p.Add("@ShopName", shop, DbType.String);
            p.Add("@BrandName", brand, DbType.String);
            p.Add("@ProductName", product, DbType.String);
            p.Add("@CategoryName", category, DbType.String);

            return await _dapper.GetAllAsync<SupplyProcurementReportRowModel>(
                "spSupplyReport_Procurement",
                p,
                CommandType.StoredProcedure);
        }

        public async Task<List<SupplyDispatchReportRowModel>> GetDispatchReportAsync(DateTime? startDate, DateTime? endDate, string? courier, string? brand, string? product, string? category, string? shipmentStatus)
        {
            var p = new DynamicParameters();
            p.Add("@StartDate", startDate, DbType.DateTime2);
            p.Add("@EndDate", endDate, DbType.DateTime2);
            p.Add("@CourierName", courier, DbType.String);
            p.Add("@BrandName", brand, DbType.String);
            p.Add("@ProductName", product, DbType.String);
            p.Add("@CategoryName", category, DbType.String);
            p.Add("@ShipmentStatus", shipmentStatus, DbType.String);

            return await _dapper.GetAllAsync<SupplyDispatchReportRowModel>(
                "spSupplyReport_Dispatch",
                p,
                CommandType.StoredProcedure);
        }

        public async Task<List<SupplyMonthlyDispatchSummaryModel>> GetMonthlyDispatchSummaryAsync(DateTime? startDate, DateTime? endDate)
        {
            var p = new DynamicParameters();
            p.Add("@StartDate", startDate, DbType.DateTime2);
            p.Add("@EndDate", endDate, DbType.DateTime2);

            return await _dapper.GetAllAsync<SupplyMonthlyDispatchSummaryModel>(
                "spSupplyReport_MonthlyDispatchSummary",
                p,
                CommandType.StoredProcedure);
        }
    }
}
