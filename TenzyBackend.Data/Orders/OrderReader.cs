using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.OrderEntity;

namespace TenzyBackend.Data.Orders
{
    public class OrderReader : IOrderReader
    {
        private readonly DapperMethods _dapper;

        public OrderReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<List<OrderEntity>> GetAllAsync(int pageSize, int offset, string? status, Guid? userId)
        {
            var p = new DynamicParameters();
            p.Add("@PageSize", pageSize, DbType.Int32);
            p.Add("@Offset",   offset,   DbType.Int32);
            p.Add("@Status",   status,   DbType.String);
            p.Add("@UserId",   userId,   DbType.Guid);

            return await _dapper.GetAllAsync<OrderEntity>(
                "spOrder_GetAll", p, CommandType.StoredProcedure);
        }

        public async Task<OrderEntity?> GetByIdAsync(int id)
        {
            using var db = _dapper._context.CreateConnection();
            if (db.State == ConnectionState.Closed) db.Open();

            var p = new DynamicParameters();
            p.Add("@Id", id, DbType.Int32);

            using var multi = await db.QueryMultipleAsync(
                "spOrder_GetById", p, commandType: CommandType.StoredProcedure);

            var order = (await multi.ReadAsync<OrderEntity>()).FirstOrDefault();
            if (order == null) return null;

            order.Items = (await multi.ReadAsync<OrderItemEntity>()).ToList();
            return order;
        }

        public async Task<List<OrderEntity>> GetByUserIdAsync(Guid userId, int pageSize, int offset)
        {
            var p = new DynamicParameters();
            p.Add("@UserId",   userId,   DbType.Guid);
            p.Add("@PageSize", pageSize, DbType.Int32);
            p.Add("@Offset",   offset,   DbType.Int32);

            return await _dapper.GetAllAsync<OrderEntity>(
                "spOrder_GetByUserId", p, CommandType.StoredProcedure);
        }
    }
}
