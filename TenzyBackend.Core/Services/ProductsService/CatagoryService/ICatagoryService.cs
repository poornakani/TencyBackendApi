using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.CatagoryService
{
    public interface ICatagoryService
    {
        Task<int> CreateCatagoryAsync(CatagoryModel catagoryModel);
        Task<bool> UpdateCatagoryAsync(CatagoryModel catagoryModel);
        Task<bool> DeactiveCatagoryAsync(int catagoryId);
        Task<bool> ActiveCatagoryAsync(int catagoryId);
        Task<CatagoryModel?> GetCatagoryByIdAsync(int catagoryId);
        Task<List<CatagoryModel>> GetAllCatagoriesAsync();
    }
}
