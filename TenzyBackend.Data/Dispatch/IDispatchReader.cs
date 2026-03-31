using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Entity.DispatchEntity;

namespace TenzyBackend.Data.Dispatch
{
    public interface IDispatchReader
    {
        Task<List<DispatchEntity>> GetPendingAsync();
    }
}
