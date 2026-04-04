using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using TenzyBackend.Core.Services.ProductsService.ConcernService;
using TenzyBackend.Models.ProductsModels;

namespace TencyBackendApi.Controllers
{
    [Authorize]
    [Route("api/concerns")]
    [ApiController]
    public class ConcerntypeController : ControllerBase
    {
        private readonly IConcernService _concernService;

        public ConcerntypeController(IConcernService concernService)
        {
            _concernService = concernService;
        }

        // GET: api/concerns
        [HttpGet]
        public async Task<IActionResult> GetAllConcerns()
        {
            var concerns = await _concernService.GetAllConcernsAsync();
            return Ok(concerns);
        }

        // GET: api/concerns/5
        [HttpGet("{id:int}", Name = "GetConcernById")]
        public async Task<IActionResult> GetConcernById(int id)
        {
            if (id <= 0) return BadRequest();
            var concern = await _concernService.GetConcernByIdAsync(id);
            if (concern == null) return NotFound();
            return Ok(concern);
        }

        // POST: api/concerns
        [HttpPost]
        public async Task<IActionResult> CreateConcern([FromBody] ConcernTypeModel concernModel)
        {
            if (concernModel == null) return BadRequest();
            var newId = await _concernService.CreateConcernAsync(concernModel);
            if (newId <= 0) return BadRequest();
            return CreatedAtRoute("GetConcernById", new { id = newId }, concernModel);
        }

        // POST: api/concerns/5/update
        [HttpPost("{id:int}/update")]
        public async Task<IActionResult> UpdateConcern(int id, [FromBody] ConcernTypeModel concernModel)
        {
            if (id <= 0 || concernModel == null) return BadRequest();

            // If your model contains an Id property, ensure consistency here before updating.
            var updated = await _concernService.UpdateConcernAsync(concernModel);
            if (!updated) return NotFound();
            return NoContent();
        }

        // POST: api/concerns/5/activate
        [HttpPost("{id:int}/activate")]
        public async Task<IActionResult> ActivateConcern(int id)
        {
            if (id <= 0) return BadRequest();
            var ok = await _concernService.ActiveConcernAsync(id);
            if (!ok) return NotFound();
            return NoContent();
        }

        // POST: api/concerns/5/deactivate
        [HttpPost("{id:int}/deactivate")]
        public async Task<IActionResult> DeactivateConcern(int id)
        {
            if (id <= 0) return BadRequest();
            var ok = await _concernService.DeactiveConcernAsync(id);
            if (!ok) return NotFound();
            return NoContent();
        }
    }
}
