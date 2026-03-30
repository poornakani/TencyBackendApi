using Dapper;
using System;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.ProcurementModels;

namespace TenzyBackend.Data.Procurement
{
    public class ProcurementWriter : IProcurementWriter
    {
        private readonly DapperMethods _dapper;

        public ProcurementWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<int> CreateOrderAsync(CreateProcurementOrderRequest request, Guid createdByUserId)
        {
            // Insert order header
            var p = new DynamicParameters();
            p.Add("@OrderReference",  request.OrderReference,  DbType.String);
            p.Add("@SupplierName",    request.SupplierName,    DbType.String);
            p.Add("@OrderDate",       request.OrderDate,       DbType.Date);
            p.Add("@GbpToLkr",        request.GbpToLkr,        DbType.Decimal);
            p.Add("@CourierCharges",  request.CourierCharges,  DbType.Decimal);
            p.Add("@CustomsDuty",     request.CustomsDuty,     DbType.Decimal);
            p.Add("@OtherCharges",    request.OtherCharges,    DbType.Decimal);
            p.Add("@Notes",           request.Notes,           DbType.String);
            p.Add("@CreatedByUserId", createdByUserId,         DbType.Guid);

            int orderId = await _dapper.InsertAsync<int>(
                "spProcurementOrder_Insert", p, CommandType.StoredProcedure);

            // Insert all line items
            foreach (var item in request.Items)
            {
                var ip = new DynamicParameters();
                ip.Add("@ProcurementOrderId", orderId,          DbType.Int32);
                ip.Add("@ProductId",          item.ProductId,   DbType.Int32);
                ip.Add("@ProductName",        item.ProductName, DbType.String);
                ip.Add("@Quantity",           item.Quantity,    DbType.Int32);
                ip.Add("@UnitPriceGbp",       item.UnitPriceGbp,DbType.Decimal);

                await _dapper.InsertAsync<int>(
                    "spProcurementItem_Insert", ip, CommandType.StoredProcedure);
            }

            return orderId;
        }

        public async Task<bool> UpdateStatusAsync(int orderId, string status, Guid? approvedByUserId = null)
        {
            var p = new DynamicParameters();
            p.Add("@Id",               orderId,          DbType.Int32);
            p.Add("@Status",           status,           DbType.String);
            p.Add("@ApprovedByUserId", approvedByUserId, DbType.Guid);

            int rows = await _dapper.ExecuteAsync(
                "spProcurementOrder_UpdateStatus", p, CommandType.StoredProcedure);
            return rows > 0;
        }
    }
}
