using System.Threading.Tasks;
using TenzyBackend.Models.OrderModels;

namespace TenzyBackend.Data.Orders
{
    public interface IOrderWriter
    {
        Task<int> CreateOrderAsync(CreateOrderRequest request);
        Task<bool> UpdateStatusAsync(int orderId, string status);
    }
}
