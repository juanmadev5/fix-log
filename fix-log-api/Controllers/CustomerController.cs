using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Common;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace fix_log_api.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class CustomerController(ICustomerService service) : ControllerBase
    {
        private readonly ICustomerService _service = service;

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _service.GetAll();
            return result.Status == Status.SUCCESS ? Ok(result) : NotFound(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetById(id);
            return result.Status == Status.FOUND ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create(CreateCustomerDto dto)
        {
            var result = await _service.Create(dto);
            return result.Status == Status.SUCCESS ? CreatedAtAction(nameof(GetById), new { id = result.Response!.Id }, result) : BadRequest(result);
        }

        [HttpPut]
        public async Task<IActionResult> Edit(ResponseCustomerDto dto)
        {
            var result = await _service.Edit(dto);
            return result.Status == Status.SUCCESS ? Ok(result) : NotFound(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _service.Delete(id);
            return result.Status == Status.SUCCESS ? Ok(result) : NotFound(result);
        }
    }
}
