using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.ProductsService.ProductCatalogService;
using TenzyBackend.Models.ApiResponseModels;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/products")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly IProductCatalogService _productService;

        public ProductsController(IProductCatalogService productService)
        {
            _productService = productService;
        }

        // GET /api/products — public, used by storefront (insale only)
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll()
        {
            var result = await _productService.GetAllProductsAsync();
            return Ok(new ApiResponseModel { result = true, response = result });
        }

        // GET /api/products/admin — admin only, returns all products regardless of insale
        [HttpGet("admin")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> GetAllAdmin()
        {
            var result = await _productService.GetAllProductsAdminAsync();
            return Ok(new ApiResponseModel { result = true, response = result });
        }

        // GET /api/products/{id} — public
        [HttpGet("{id:int}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetById(int id)
        {
            var product = await _productService.GetProductByIdAsync(id);
            return Ok(new ApiResponseModel { result = true, response = product });
        }

        // POST /api/products — admin only
        [HttpPost]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> Create([FromBody] CreateProductRequest request)
        {
            var newId = await _productService.CreateProductAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = newId },
                new ApiResponseModel { result = true, message = "Product created.", response = new { id = newId } });
        }

        // POST /api/products/{id}/update — admin only
        [HttpPost("{id:int}/update")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateProductRequest request)
        {
            request.ProductId = id;
            await _productService.UpdateProductAsync(request);
            return Ok(new ApiResponseModel { result = true, message = "Product updated." });
        }

        // POST /api/products/{id}/delete — admin only (soft delete / deactivate)
        [HttpPost("{id:int}/delete")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> Deactivate(int id)
        {
            await _productService.DeactivateProductAsync(id);
            return Ok(new ApiResponseModel { result = true, message = "Product deactivated." });
        }

        // GET /api/products/{id}/concerns — admin only
        [HttpGet("{id:int}/concerns")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> GetConcerns(int id)
        {
            var concernIds = await _productService.GetProductConcernIdsAsync(id);
            return Ok(new ApiResponseModel { result = true, response = concernIds });
        }

        // GET /api/products/{id}/payment-options — admin only
        [HttpGet("{id:int}/payment-options")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> GetPaymentOptions(int id)
        {
            var options = await _productService.GetProductPaymentOptionsAsync(id);
            return Ok(new ApiResponseModel { result = true, response = options });
        }
    }
}
