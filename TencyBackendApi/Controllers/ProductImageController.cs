using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.ProductsService.ProductImagesService;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/productimage")]
    [ApiController]
    public class ProductImageController : ControllerBase
    {
        private readonly IProductImageService _productImageService;

        public ProductImageController(IProductImageService productImageService)
        {
            _productImageService = productImageService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateProductImage([FromBody] ProductImageModel productImageModel)
        {
            if (productImageModel == null)
                return BadRequest(new { Success = false, Message = "Product image data is required." });

            var newId = await _productImageService.CreateProductImageAsync(productImageModel);

            if (newId <= 0)
                return BadRequest(new { Success = false, Message = "Failed to create product image." });

            return Ok(new
            {
                Success = true,
                Message = "Product image created successfully.",
                ProductImageId = newId
            });
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateProductImage([FromBody] ProductImageModel productImageModel)
        {
            if (productImageModel == null)
                return BadRequest(new { Success = false, Message = "Product image data is required." });

            var result = await _productImageService.UpdateProductImageAsync(productImageModel);

            if (!result)
                return BadRequest(new { Success = false, Message = "Failed to update product image." });

            return Ok(new
            {
                Success = true,
                Message = "Product image updated successfully."
            });
        }

        [HttpPost("deactive/{productImageId:int}")]
        public async Task<IActionResult> DeactiveProductImage([FromRoute] int productImageId)
        {
            var result = await _productImageService.DeactiveProductImageAsync(productImageId);

            if (!result)
                return BadRequest(new { Success = false, Message = "Failed to deactive product image." });

            return Ok(new
            {
                Success = true,
                Message = "Product image deactivated successfully."
            });
        }

        [HttpPost("active/{productImageId:int}")]
        public async Task<IActionResult> ActiveProductImage([FromRoute] int productImageId)
        {
            var result = await _productImageService.ActiveProductImageAsync(productImageId);

            if (!result)
                return BadRequest(new { Success = false, Message = "Failed to activate product image." });

            return Ok(new
            {
                Success = true,
                Message = "Product image activated successfully."
            });
        }

        [HttpGet("{productImageId:int}")]
        public async Task<IActionResult> GetProductImageById([FromRoute] int productImageId)
        {
            var productImage = await _productImageService.GetProductImageByIdAsync(productImageId);

            if (productImage == null)
                return NotFound(new { Success = false, Message = "Product image not found." });

            return Ok(new
            {
                Success = true,
                Data = productImage
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetAllProductImages()
        {
            var productImages = await _productImageService.GetAllProductImagesAsync();

            return Ok(new
            {
                Success = true,
                Data = productImages
            });
        }
    }
}