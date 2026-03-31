using Dapper;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.OrderModels;

namespace TenzyBackend.Data.Orders
{
    public class OrderWriter : IOrderWriter
    {
        private readonly DapperMethods _dapper;

        public OrderWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<int> CreateOrderAsync(CreateOrderRequest request)
        {
            var p = new DynamicParameters();
            p.Add("@UserId",          request.UserId,          DbType.Guid);
            p.Add("@PaymentMethod",   request.PaymentMethod,   DbType.String);
            p.Add("@ShippingName",    request.ShippingName,    DbType.String);
            p.Add("@ShippingPhone",   request.ShippingPhone,   DbType.String);
            p.Add("@ShippingAddress", request.ShippingAddress, DbType.String);
            p.Add("@ShippingCity",    request.ShippingCity,    DbType.String);
            p.Add("@SubtotalLkr",     request.SubtotalLkr,     DbType.Decimal);
            p.Add("@ShippingFee",     request.ShippingFee,     DbType.Decimal);
            p.Add("@DiscountLkr",     request.DiscountLkr,     DbType.Decimal);
            p.Add("@TotalLkr",        request.TotalLkr,        DbType.Decimal);
            p.Add("@Notes",           request.Notes,           DbType.String);

            int orderId = await _dapper.InsertAsync<int>(
                "spOrder_Insert", p, CommandType.StoredProcedure);

            foreach (var item in request.Items)
            {
                var ip = new DynamicParameters();
                ip.Add("@OrderId",     orderId,           DbType.Int32);
                ip.Add("@ProductId",   item.ProductId,    DbType.Int32);
                ip.Add("@ProductName", item.ProductName,  DbType.String);
                ip.Add("@Qty",         item.Qty,          DbType.Int32);
                ip.Add("@UnitPrice",   item.UnitPrice,    DbType.Decimal);
                ip.Add("@LineTotal",   item.Qty * item.UnitPrice, DbType.Decimal);

                await _dapper.InsertAsync<int>(
                    "spOrderItem_Insert", ip, CommandType.StoredProcedure);
            }

            return orderId;
        }

        public async Task<bool> UpdateStatusAsync(int orderId, string status)
        {
            var p = new DynamicParameters();
            p.Add("@Id",     orderId, DbType.Int32);
            p.Add("@Status", status,  DbType.String);

            int rows = await _dapper.ExecuteAsync(
                "spOrder_UpdateStatus", p, CommandType.StoredProcedure);
            return rows > 0;
        }
    }
}
