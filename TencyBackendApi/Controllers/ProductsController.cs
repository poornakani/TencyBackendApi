using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using TenzyBackend.Core.Services.AuditService;
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
        private readonly IAuditService _audit;

        public ProductsController(IProductCatalogService productService, IAuditService audit)
        {
            _productService = productService;
            _audit          = audit;
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
            var adminId = GetAdminUserId();
            int newId   = 0;
            try
            {
                newId = await _productService.CreateProductAsync(request);
                if (adminId.HasValue)
                    await _audit.LogAdminActionAsync(adminId.Value, "Create Product",
                        "Product", newId.ToString(),
                        newValues: JsonSerializer.Serialize(request),
                        ipAddress: GetIp());
                return CreatedAtAction(nameof(GetById), new { id = newId },
                    new ApiResponseModel { result = true, message = "Product created.", response = new { id = newId } });
            }
            catch (Exception ex)
            {
                if (adminId.HasValue)
                    await TryAuditError(adminId.Value, "Create Product FAILED", "Product", null,
                        $"{ex.GetType().Name}: {ex.Message}", JsonSerializer.Serialize(request));
                throw;
            }
        }

        // POST /api/products/{id}/update — admin only
        [HttpPost("{id:int}/update")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateProductRequest request)
        {
            var adminId = GetAdminUserId();
            request.ProductId = id;
            try
            {
                // Snapshot before
                var before = await _productService.GetProductByIdAsync(id);
                await _productService.UpdateProductAsync(request);
                if (adminId.HasValue)
                    await _audit.LogAdminActionAsync(adminId.Value, "Update Product",
                        "Product", id.ToString(),
                        oldValues: JsonSerializer.Serialize(before),
                        newValues: JsonSerializer.Serialize(request),
                        ipAddress: GetIp());
                return Ok(new ApiResponseModel { result = true, message = "Product updated." });
            }
            catch (Exception ex)
            {
                if (adminId.HasValue)
                    await TryAuditError(adminId.Value, "Update Product FAILED", "Product", id.ToString(),
                        $"{ex.GetType().Name}: {ex.Message}", JsonSerializer.Serialize(request));
                throw;
            }
        }

        // POST /api/products/{id}/delete — admin only (soft delete / deactivate)
        [HttpPost("{id:int}/delete")]
        [Authorize(Roles = "3")]
        public async Task<IActionResult> Deactivate(int id)
        {
            var adminId = GetAdminUserId();
            try
            {
                await _productService.DeactivateProductAsync(id);
                if (adminId.HasValue)
                    await _audit.LogAdminActionAsync(adminId.Value, "Deactivate Product",
                        "Product", id.ToString(), ipAddress: GetIp());
                return Ok(new ApiResponseModel { result = true, message = "Product deactivated." });
            }
            catch (Exception ex)
            {
                if (adminId.HasValue)
                    await TryAuditError(adminId.Value, "Deactivate Product FAILED", "Product", id.ToString(),
                        $"{ex.GetType().Name}: {ex.Message}");
                throw;
            }
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

        /* ── helpers ───────────────────────────────────────────────────────── */
        private Guid? GetAdminUserId()
        {
            var s = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(s, out var g) ? g : null;
        }

        private string? GetIp() => HttpContext.Connection.RemoteIpAddress?.ToString();

        private async Task TryAuditError(Guid adminId, string action, string entityType,
            string? entityId, string errorDetail, string? requestJson = null)
        {
            try
            {
                await _audit.LogAdminActionAsync(adminId, action, entityType, entityId,
                    newValues: requestJson,
                    oldValues: errorDetail,
                    ipAddress: GetIp());
            }
            catch { /* audit must never throw */ }
        }
    }
}
