using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.ProductsService.BrandService;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Authorize]
    [Route("api/brands")]
    [ApiController]
    public class BrandController : ControllerBase
    {
        private readonly IBrandService _brandService;

        public BrandController(IBrandService brandService)
        {
            _brandService = brandService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllBrands()
        {
            var brands = await _brandService.GetAllBrandsAsync();
            return Ok(new
            {
                success = true,
                response = brands
            });
        }

        [HttpGet("{brandId:int}")]
        public async Task<IActionResult> GetBrandById(int brandId)
        {
            var brand = await _brandService.GetBrandByIdAsync(brandId);
            return Ok(new
            {
                success = true,
                response = brand
            });
        }

        
        [HttpPost]
        public async Task<IActionResult> CreateBrand([FromBody] BrandModel brandEntity)
        {
            var brandId = await _brandService.CreateBrandAsync(brandEntity);
            return Ok(new
            {
                success = true,
                message = "Brand created successfully.",
                response = brandId
            });
        }

        [HttpPost("{brandId:int}")]
        public async Task<IActionResult> DeleteBrand(int brandId)
        {
            var result = await _brandService.DeactiveBrandAsync(brandId);
            return Ok(new
            {
                success = result,
                message = "Brand deleted successfully."
            });
        }

        [HttpPut]
        public async Task<IActionResult> UpdateBrand([FromBody] BrandModel brandEntity)
        {
            var result = await _brandService.UpdateBrandAsync(brandEntity);
            return Ok(new
            {
                success = result,
                message = "Brand updated successfully."
            });
        }

       

       
    }
}