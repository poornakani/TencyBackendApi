using Dapper;
using System;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.SupplyChainModels;

namespace TenzyBackend.Data.SupplyChain
{
    public class SupplyChainWriter : ISupplyChainWriter
    {
        private readonly DapperMethods _dapper;

        public SupplyChainWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<int> SaveProcurementAsync(SaveProcurementRequest request, string itemsJson, string discountsJson, string allocationsJson, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ProcurementId", request.ProcurementId, DbType.Int32);
            p.Add("@ProcurementReference", request.ProcurementReference, DbType.String);
            p.Add("@ShopName", request.ShopName, DbType.String);
            p.Add("@PurchaseDate", request.PurchaseDate, DbType.DateTime2);
            p.Add("@InvoiceReference", request.InvoiceReference, DbType.String);
            p.Add("@PurchaseNote", request.PurchaseNote, DbType.String);
            p.Add("@EnteredByUserId", userId, DbType.Guid);
            p.Add("@ItemsJson", itemsJson, DbType.String);
            p.Add("@DiscountsJson", discountsJson, DbType.String);
            p.Add("@AllocationsJson", allocationsJson, DbType.String);

            return await _dapper.InsertAsync<int>("spSupplyProcurement_Save", p, CommandType.StoredProcedure);
        }

        public async Task<int> SaveDispatchAsync(SaveDispatchRequest request, string itemsJson, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ShipmentId", request.ShipmentId, DbType.Int32);
            p.Add("@DispatchReference", request.DispatchReference, DbType.String);
            p.Add("@DispatchDate", request.DispatchDate, DbType.DateTime2);
            p.Add("@CourierName", request.CourierName, DbType.String);
            p.Add("@ParcelNumber", request.ParcelNumber, DbType.String);
            p.Add("@ShipmentStatus", request.ShipmentStatus, DbType.String);
            p.Add("@Notes", request.Notes, DbType.String);
            p.Add("@CreatedByUserId", userId, DbType.Guid);
            p.Add("@ItemsJson", itemsJson, DbType.String);

            return await _dapper.InsertAsync<int>("spSupplyDispatch_Save", p, CommandType.StoredProcedure);
        }

        public async Task<int> AddShipmentChargeAsync(int shipmentId, AddShipmentChargeRequest request, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ShipmentId", shipmentId, DbType.Int32);
            p.Add("@ChargeType", request.ChargeType, DbType.String);
            p.Add("@CurrencyCode", request.CurrencyCode, DbType.String);
            p.Add("@Amount", request.Amount, DbType.Decimal);
            p.Add("@ChargeDate", request.ChargeDate, DbType.DateTime2);
            p.Add("@Notes", request.Notes, DbType.String);
            p.Add("@EnteredByUserId", userId, DbType.Guid);

            return await _dapper.InsertAsync<int>("spSupplyDispatch_AddCharge", p, CommandType.StoredProcedure);
        }

        public async Task<int> SaveArrivalAsync(SaveArrivalRequest request, string itemsJson, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@ArrivalVerificationId", request.ArrivalVerificationId, DbType.Int32);
            p.Add("@ShipmentId", request.ShipmentId, DbType.Int32);
            p.Add("@VerificationDate", request.VerificationDate, DbType.DateTime2);
            p.Add("@VerificationStatus", request.VerificationStatus, DbType.String);
            p.Add("@Notes", request.Notes, DbType.String);
            p.Add("@VerifiedByUserId", userId, DbType.Guid);
            p.Add("@ItemsJson", itemsJson, DbType.String);

            return await _dapper.InsertAsync<int>("spSupplyArrival_Save", p, CommandType.StoredProcedure);
        }

        public async Task<int> SavePricingAsync(SavePricingRequest request, Guid userId)
        {
            var p = new DynamicParameters();
            p.Add("@PricingId", request.PricingId, DbType.Int32);
            p.Add("@ArrivalItemId", request.ArrivalItemId, DbType.Int32);
            p.Add("@SellingPrice", request.SellingPrice, DbType.Decimal);
            p.Add("@CustomerDiscountPercent", request.CustomerDiscountPercent, DbType.Decimal);
            p.Add("@CustomerDiscountAmount", request.CustomerDiscountAmount, DbType.Decimal);
            p.Add("@PricingNotes", request.PricingNotes, DbType.String);
            p.Add("@IsApproved", request.IsApproved, DbType.Boolean);
            p.Add("@ApprovedByUserId", userId, DbType.Guid);

            return await _dapper.InsertAsync<int>("spSupplyPricing_Save", p, CommandType.StoredProcedure);
        }
    }
}
