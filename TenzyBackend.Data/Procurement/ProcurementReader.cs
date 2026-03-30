using Dapper;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.ProcurementEntity;

namespace TenzyBackend.Data.Procurement
{
    public class ProcurementReader : IProcurementReader
    {
        private readonly DapperMethods _dapper;

        public ProcurementReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<List<ProcurementOrderEntity>> GetAllAsync()
        {
            return await _dapper.GetAllAsync<ProcurementOrderEntity>(
                "spProcurementOrder_GetAll",
                commandType: CommandType.StoredProcedure);
        }

        public async Task<ProcurementOrderEntity?> GetByIdAsync(int id)
        {
            // SP returns two result sets: order + items
            // Use raw Dapper multi-result via DapperContext
            using var db = _dapper._context.CreateConnection();
            if (db.State == ConnectionState.Closed) db.Open();

            var p = new DynamicParameters();
            p.Add("@Id", id, DbType.Int32);

            using var multi = await db.QueryMultipleAsync(
                "spProcurementOrder_GetById", p, commandType: CommandType.StoredProcedure);

            var order = (await multi.ReadAsync<ProcurementOrderEntity>()).FirstOrDefault();
            if (order == null) return null;

            order.Items = (await multi.ReadAsync<ProcurementItemEntity>()).ToList();
            return order;
        }
    }
}
