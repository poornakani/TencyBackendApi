using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.CustomerService;
using TenzyBackend.Models.ApiResponseModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/admin/customers")]
    [ApiController]
    [Authorize(Roles = "1")]
    public class CustomersController : ControllerBase
    {
        private readonly ICustomerService _customerService;

        public CustomersController(ICustomerService customerService)
        {
            _customerService = customerService;
        }

        /// <summary>GET /api/admin/customers?page=1&pageSize=20&search=</summary>
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] string? search = null)
        {
            var customers = await _customerService.GetAllCustomersAsync(page, pageSize, search);
            return Ok(new ApiResponseModel
            {
                result = true,
                message = "Customers retrieved.",
                response = customers
            });
        }

        /// <summary>GET /api/admin/customers/{id}</summary>
        [HttpGet("{id:guid}")]
        public async Task<IActionResult> GetById(Guid id)
        {
            var customer = await _customerService.GetCustomerByIdAsync(id);
            if (customer == null)
                return NotFound(new ApiResponseModel
                {
                    result = false,
                    message = "Customer not found."
                });

            return Ok(new ApiResponseModel
            {
                result = true,
                message = "Customer retrieved.",
                response = customer
            });
        }
    }
}
