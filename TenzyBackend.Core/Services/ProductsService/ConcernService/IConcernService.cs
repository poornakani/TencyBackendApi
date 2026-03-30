using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ConcernService
{
    public interface IConcernService
    {
        Task<int> CreateConcernAsync(ConcernTypeModel concernModel);
        Task<bool> UpdateConcernAsync(ConcernTypeModel concernModel);
        Task<bool> DeactiveConcernAsync(int concernId);
        Task<bool> ActiveConcernAsync(int concernId);
        Task<ConcernTypeModel?> GetConcernByIdAsync(int concernId);
        Task<List<ConcernTypeModel>> GetAllConcernsAsync();
    }
}
