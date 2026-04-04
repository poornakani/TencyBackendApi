using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.ProductsService.CatagoryService;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Authorize]
    [Route("api/categories")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly ICatagoryService _categoryService;

        public CategoryController(ICatagoryService categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllCategories()
        {
            var categories = await _categoryService.GetAllCatagoriesAsync();
            return Ok(new
            {
                success = true,
                response = categories
            });
        }

        [HttpGet("{categoryId:int}")]
        public async Task<IActionResult> GetCategoryById(int categoryId)
        {
            var category = await _categoryService.GetCatagoryByIdAsync(categoryId);
            return Ok(new
            {
                success = true,
                response = category
            });
        }

        [HttpPost]
        public async Task<IActionResult> CreateCategory([FromBody] CatagoryModel categoryModel)
        {
            var categoryId = await _categoryService.CreateCatagoryAsync(categoryModel);
            return Ok(new
            {
                success = true,
                message = "Category created successfully.",
                response = categoryId
            });
        }

        [HttpPost("{categoryId:int}")]
        public async Task<IActionResult> DeactivateCategory(int categoryId)
        {
            var result = await _categoryService.DeactiveCatagoryAsync(categoryId);
            return Ok(new
            {
                success = result,
                message = "Category deleted successfully."
            });
        }


        [HttpPost("{categoryId:int}/activate")]
        public async Task<IActionResult> ActivateCategory(int categoryId)
        {
            var result = await _categoryService.ActiveCatagoryAsync(categoryId);
            return Ok(new
            {
                success = result,
                message = "Category deleted successfully."
            });
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateCategory([FromBody] CatagoryModel categoryModel)
        {
            var result = await _categoryService.UpdateCatagoryAsync(categoryModel);
            return Ok(new
            {
                success = result,
                message = "Category updated successfully."
            });
        }
    }
}