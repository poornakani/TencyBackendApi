using Dapper;
using System;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Models.DispatchModels;

namespace TenzyBackend.Data.Dispatch
{
    public class DispatchWriter : IDispatchWriter
    {
        private readonly DapperMethods _dapper;

        public DispatchWriter(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<int> UpsertDispatchAsync(UpsertDispatchRequest request, Guid createdByUserId)
        {
            var p = new DynamicParameters();
            p.Add("@OrderId",           request.OrderId,           DbType.Int32);
            p.Add("@TrackingId",        request.TrackingId,        DbType.String);
            p.Add("@Courier",           request.Courier,           DbType.String);
            p.Add("@EstimatedDelivery", request.EstimatedDelivery, DbType.Date);
            p.Add("@Notes",             request.Notes,             DbType.String);
            p.Add("@CreatedByUserId",   createdByUserId,           DbType.Guid);

            return await _dapper.InsertAsync<int>(
                "spDispatch_Upsert", p, CommandType.StoredProcedure);
        }

        public async Task<bool> MarkDeliveredAsync(int orderId)
        {
            var p = new DynamicParameters();
            p.Add("@OrderId", orderId, DbType.Int32);

            int rows = await _dapper.ExecuteAsync(
                "spDispatch_MarkDelivered", p, CommandType.StoredProcedure);
            return rows > 0;
        }
    }
}
