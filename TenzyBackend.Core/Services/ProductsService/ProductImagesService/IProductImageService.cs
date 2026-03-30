using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ProductImagesService
{
    public interface IProductImageService
    {
        Task<int> CreateProductImageAsync(ProductImageModel productImageModel);
        Task<bool> UpdateProductImageAsync(ProductImageModel productImageModel);
        Task<bool> DeactiveProductImageAsync(int productImageId);
        Task<bool> ActiveProductImageAsync(int productImageId);
        Task<ProductImageModel?> GetProductImageByIdAsync(int productImageId);
        Task<List<ProductImageModel>> GetAllProductImagesAsync();
    }
}
