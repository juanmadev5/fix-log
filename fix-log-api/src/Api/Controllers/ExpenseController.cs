using Asp.Versioning;
using fix_log_api.Application.Common;
using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Exceptions;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace fix_log_api.Api.Controllers
{
    /// <summary>Operational expenses recorded by the authenticated user.</summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    public class ExpenseController(IExpenseService service, IValidator<CreateExpenseDto> validator) : ApiControllerBase
    {
        private readonly IExpenseService _service = service;
        private readonly IValidator<CreateExpenseDto> _validator = validator;

        /// <summary>Lists the authenticated user's expenses, paginated.</summary>
        [HttpGet]
        [ProducesResponseType(typeof(PagedResult<ResponseExpenseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAll([FromQuery] int page = PaginationDefaults.DefaultPage, [FromQuery(Name = "page_size")] int pageSize = PaginationDefaults.DefaultPageSize)
        {
            var result = await _service.GetAll(GetUserId(), page, pageSize);
            return Ok(result);
        }

        /// <summary>Gets a single expense owned by the authenticated user.</summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ResponseExpenseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetById(id, GetUserId());
            return Ok(result);
        }

        /// <summary>Creates an expense for the authenticated user.</summary>
        [HttpPost]
        [ProducesResponseType(typeof(ResponseExpenseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        public async Task<IActionResult> Create(CreateExpenseDto dto)
        {
            var validation = await _validator.ValidateAsync(dto);
            if (!validation.IsValid)
                throw new ValidationFailedException(validation.Errors.Select(error => new FieldError(error.PropertyName, error.ErrorMessage)).ToList());

            var result = await _service.Create(dto, GetUserId());
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }

        /// <summary>Replaces an expense owned by the authenticated user.</summary>
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(ResponseExpenseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Edit(int id, CreateExpenseDto dto)
        {
            var validation = await _validator.ValidateAsync(dto);
            if (!validation.IsValid)
                throw new ValidationFailedException(validation.Errors.Select(error => new FieldError(error.PropertyName, error.ErrorMessage)).ToList());

            var result = await _service.Edit(id, dto, GetUserId());
            return Ok(result);
        }

        /// <summary>Deletes an expense owned by the authenticated user.</summary>
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
