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

        // GET /api/products — public, used by storefront
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll()
        {
            var result = await _productService.GetAllProductsAsync();
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
        [Authorize(Roles = "1")]
        public async Task<IActionResult> Create([FromBody] CreateProductRequest request)
        {
            var newId = await _productService.CreateProductAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = newId },
                new ApiResponseModel { result = true, message = "Product created.", response = new { id = newId } });
        }

        // PUT /api/products/{id} — admin only
        [HttpPut("{id:int}")]
        [Authorize(Roles = "1")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateProductRequest request)
        {
            request.ProductId = id;
            await _productService.UpdateProductAsync(request);
            return Ok(new ApiResponseModel { result = true, message = "Product updated." });
        }

        // DELETE /api/products/{id} — admin only (soft delete / deactivate)
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "1")]
        public async Task<IActionResult> Deactivate(int id)
        {
            await _productService.DeactivateProductAsync(id);
            return Ok(new ApiResponseModel { result = true, message = "Product deactivated." });
        }
    }
}
