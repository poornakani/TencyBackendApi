using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.ProductsService.ProductFAQService;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Authorize]
    [Route("api/productfaq")]
    [ApiController]
    public class ProductFAQController : ControllerBase
    {
        private readonly IProductFAQService _productFAQService;
        public ProductFAQController(IProductFAQService productFAQService)
        {
            _productFAQService= productFAQService;
        }

        // GET: api/productFAQ
        [HttpGet]
        public async Task<IActionResult> GetAllpaymentTypes()
        {
            var concerns = await _productFAQService.GetAllProductFAQsAsync();
            return Ok(concerns);
        }

        // GET: api/productFAQ/5
        [HttpGet("{id:int}", Name = "GetproductFAQById")]
        public async Task<IActionResult> GetpaymentTypesById(int id)
        {
            if (id <= 0) return BadRequest();
            var concern = await _productFAQService.GetProductFAQByIdAsync(id);
            if (concern == null) return NotFound();
            return Ok(concern);
        }

        // POST: api/productFAQ
        [HttpPost]
        public async Task<IActionResult> CreatepaymentTypes([FromBody] ProductFAQModel productFaqModel)
        {
            if (productFaqModel == null) return BadRequest();
            var newId = await _productFAQService.CreateProductFAQAsync(productFaqModel);
            if (newId <= 0) return BadRequest();
            productFaqModel.FAQId = newId;
            return CreatedAtRoute("GetproductFAQById", new { id = newId }, productFaqModel);
        }

        // POST: api/productFAQ/5/update
        [HttpPost("{id:int}/update")]
        public async Task<IActionResult> UpdatepaymentTypes(int id, [FromBody] ProductFAQModel productFaqModel)
        {
            if (id <= 0 || productFaqModel == null) return BadRequest();

            var updated = await _productFAQService.UpdateProductFAQAsync(productFaqModel);
            if (!updated) return NotFound();
            return NoContent();
        }

        // POST: api/productFAQ/5/activate
        [HttpPost("{id:int}/activate")]
        public async Task<IActionResult> ActivatepaymentTypes(int id)
        {
            if (id <= 0) return BadRequest();
            var ok = await _productFAQService.ActiveProductFAQAsync(id);
            if (!ok) return NotFound();
            return NoContent();
        }

        // POST: api/productFAQ/5/deactivate
        [HttpPost("{id:int}/deactivate")]
        public async Task<IActionResult> DeactivatepaymentTypes(int id)
        {
            if (id <= 0) return BadRequest();
            var ok = await _productFAQService.DeactiveProductFAQAsync(id);
            if (!ok) return NotFound();
            return NoContent();
        }
    }
}
