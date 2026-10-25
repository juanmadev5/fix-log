using Asp.Versioning;
using fix_log_api.Application.Common;
using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace fix_log_api.Api.Controllers
{
    /// <summary>Customers owned by the authenticated user, with their associated reports.</summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    public class CustomerController(ICustomerService service, IValidator<CreateCustomerDto> validator) : ApiControllerBase
    {
        private readonly ICustomerService _service = service;
        private readonly IValidator<CreateCustomerDto> _validator = validator;

        /// <summary>Lists the authenticated user's customers, paginated.</summary>
        [HttpGet]
        [ProducesResponseType(typeof(PagedResult<ResponseCustomerDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAll([FromQuery] int page = PaginationDefaults.DefaultPage, [FromQuery(Name = "page_size")] int pageSize = PaginationDefaults.DefaultPageSize)
        {
            var result = await _service.GetAll(GetUserId(), page, pageSize);
            return Ok(result);
        }

        /// <summary>Gets a single customer owned by the authenticated user.</summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ResponseCustomerDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetById(id, GetUserId());
            return Ok(result);
        }

        /// <summary>Creates a customer for the authenticated user.</summary>
        [HttpPost]
        [ProducesResponseType(typeof(ResponseCustomerDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        public async Task<IActionResult> Create(CreateCustomerDto dto)
        {
            var validation = await _validator.ValidateAsync(dto);
            validation.ThrowIfInvalid();

            var result = await _service.Create(dto, GetUserId());
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }

        /// <summary>Replaces a customer owned by the authenticated user.</summary>
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(ResponseCustomerDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Edit(int id, CreateCustomerDto dto)
        {
            var validation = await _validator.ValidateAsync(dto);
            validation.ThrowIfInvalid();

            var result = await _service.Edit(id, dto, GetUserId());
            return Ok(result);
        }

        /// <summary>Deletes a customer owned by the authenticated user.</summary>
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Delete(int id)
        {
            await _service.Delete(id, GetUserId());
            return NoContent();
        }
    }
}
