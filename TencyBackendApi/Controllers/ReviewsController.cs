using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.ReviewService;
using TenzyBackend.Models.ApiResponseModels;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/reviews")]
    [ApiController]
    public class ReviewsController : ControllerBase
    {
        private readonly IReviewService _reviewService;

        public ReviewsController(IReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        // GET /api/reviews/product/{productId} — public storefront
        [HttpGet("product/{productId:int}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetByProduct(int productId)
        {
            var result = await _reviewService.GetProductReviewsAsync(productId);
            return Ok(new ApiResponseModel { result = true, response = result });
        }

        // GET /api/reviews — admin list, ?page=1&pageSize=50&isApproved=true/false/null
        [HttpGet]
        [Authorize(Roles = "1")]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50,
            [FromQuery] bool? isApproved = null)
        {
            var reviews = await _reviewService.GetAllReviewsAsync(page, pageSize, isApproved);
            return Ok(new ApiResponseModel { result = true, response = reviews });
        }

        // POST /api/reviews — authenticated user submits review
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Create([FromBody] CreateReviewRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized(new ApiResponseModel { result = false, message = "Invalid token." });

            var displayName = User.FindFirst(ClaimTypes.Name)?.Value
                           ?? User.FindFirst("name")?.Value
                           ?? "Anonymous";

            var newId = await _reviewService.AddReviewAsync(request, userId.Value, displayName);
            return Ok(new ApiResponseModel { result = true, message = "Review submitted.", response = new { id = newId } });
        }

        // PATCH /api/reviews/{id}/moderate — admin approve/reject
        [HttpPatch("{id:int}/moderate")]
        [Authorize(Roles = "1")]
        public async Task<IActionResult> Moderate(int id, [FromBody] ModerateReviewRequest request)
        {
            await _reviewService.ModerateReviewAsync(id, request.IsApproved);
            var action = request.IsApproved ? "approved" : "rejected";
            return Ok(new ApiResponseModel { result = true, message = $"Review {action}." });
        }

        private Guid? GetCurrentUserId()
        {
            var s = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(s, out var g) ? g : null;
        }
    }
}
