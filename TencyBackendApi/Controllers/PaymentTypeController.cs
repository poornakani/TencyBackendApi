using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TenzyBackend.Core.Services.ProductsService.PaymentTypeService;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Route("api/paymenttype")]
    [ApiController]
    public class PaymentTypeController : ControllerBase
    {
        private readonly IPaymentTypeService _paymentTypeService;
        public PaymentTypeController(IPaymentTypeService paymentTypeService)
        {
            _paymentTypeService= paymentTypeService;
        }
        // GET: api/paymenttype
        [HttpGet]
        public async Task<IActionResult> GetAllpaymentTypes()
        {
            var concerns = await _paymentTypeService.GetAllPaymentTypesAsync();
            return Ok(concerns);
        }

        // GET: api/paymenttype/5
        [HttpGet("{id:int}", Name = "GetPaymentTypeById")]
        public async Task<IActionResult> GetpaymentTypesById(int id)
        {
            if (id <= 0) return BadRequest();
            var concern = await _paymentTypeService.GetPaymentTypeByIdAsync(id);
            if (concern == null) return NotFound();
            return Ok(concern);
        }

        // POST: api/paymenttype
        [HttpPost]
        public async Task<IActionResult> CreatepaymentTypes([FromBody] PaymentTypeModel paymentTypeModel)
        {
            if (paymentTypeModel == null) return BadRequest();
            var newId = await _paymentTypeService.CreatePaymentTypeAsync(paymentTypeModel);
            if (newId <= 0) return BadRequest();
            return CreatedAtRoute("GetPaymentTypeById", new { id = newId }, paymentTypeModel);
        }

        // PUT: api/paymenttype/5
        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdatepaymentTypes(int id, [FromBody] PaymentTypeModel paymentTypeModel)
        {
            if (id <= 0 || paymentTypeModel == null) return BadRequest();

            var updated = await _paymentTypeService.UpdatePaymentTypeAsync(paymentTypeModel);
            if (!updated) return NotFound();
            return NoContent();
        }

        // POST: api/paymenttype/5/activate
        [HttpPost("{id:int}/activate")]
        public async Task<IActionResult> ActivatepaymentTypes(int id)
        {
            if (id <= 0) return BadRequest();
            var ok = await _paymentTypeService.ActivePaymentTypeAsync(id);
            if (!ok) return NotFound();
            return NoContent();
        }

        // POST: api/paymenttype/5/deactivate
        [HttpPost("{id:int}/deactivate")]
        public async Task<IActionResult> DeactivatepaymentTypes(int id)
        {
            if (id <= 0) return BadRequest();
            var ok = await _paymentTypeService.DeactivePaymentTypeAsync(id);
            if (!ok) return NotFound();
            return NoContent();
        }
    }
}
