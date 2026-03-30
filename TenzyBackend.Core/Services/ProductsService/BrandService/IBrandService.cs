using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.BrandService
{
    public interface IBrandService
    {
        Task<int> CreateBrandAsync(BrandModel brandEntity);
        Task<bool> UpdateBrandAsync(BrandModel brandEntity);
        Task<bool> DeactiveBrandAsync(int brandId);
        Task<BrandModel?> GetBrandByIdAsync(int brandId);
        Task<List<BrandModel>> GetAllBrandsAsync();
    }
}
