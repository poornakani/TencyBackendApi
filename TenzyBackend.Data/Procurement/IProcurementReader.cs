using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Entity.ProcurementEntity;

namespace TenzyBackend.Data.Procurement
{
    public interface IProcurementReader
    {
        Task<List<ProcurementOrderEntity>> GetAllAsync();
        Task<ProcurementOrderEntity?> GetByIdAsync(int id);
    }
}
