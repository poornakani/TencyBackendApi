using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using TenzyBackend.DBContext;
using TenzyBackend.Entity.DispatchEntity;

namespace TenzyBackend.Data.Dispatch
{
    public class DispatchReader : IDispatchReader
    {
        private readonly DapperMethods _dapper;

        public DispatchReader(DapperMethods dapper)
        {
            _dapper = dapper;
        }

        public async Task<List<DispatchEntity>> GetPendingAsync()
        {
            return await _dapper.GetAllAsync<DispatchEntity>(
                "spDispatch_GetPending", commandType: CommandType.StoredProcedure);
        }
    }
}
