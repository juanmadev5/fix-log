using Asp.Versioning;
using fix_log_api.Application.Common;
using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Exceptions;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace fix_log_api.Api.Controllers
{
    /// <summary>Work reports recorded by the authenticated user for their customers.</summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    public class ReportController(IReportService service, IValidator<CreateReportDto> validator) : ApiControllerBase
    {
        private readonly IReportService _service = service;
        private readonly IValidator<CreateReportDto> _validator = validator;

        /// <summary>Lists the authenticated user's reports, paginated.</summary>
        [HttpGet]
        [ProducesResponseType(typeof(PagedResult<ResponseReportDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAll([FromQuery] int page = PaginationDefaults.DefaultPage, [FromQuery] int pageSize = PaginationDefaults.DefaultPageSize)
        {
            var result = await _service.GetAll(GetUserId(), page, pageSize);
            return Ok(result);
        }

        /// <summary>Gets a single report owned by the authenticated user.</summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ResponseReportDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetById(id, GetUserId());
            return Ok(result);
        }

        /// <summary>Creates a report for the authenticated user.</summary>
        [HttpPost]
        [ProducesResponseType(typeof(ResponseReportDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        public async Task<IActionResult> Create(CreateReportDto dto)
        {
            var validation = await _validator.ValidateAsync(dto);
            if (!validation.IsValid)
                throw new ValidationFailedException(validation.Errors.Select(error => new FieldError(error.PropertyName, error.ErrorMessage)).ToList());

            var result = await _service.Create(dto, GetUserId());
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }

        /// <summary>Replaces a report owned by the authenticated user.</summary>
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(ResponseReportDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Edit(int id, CreateReportDto dto)
        {
            var validation = await _validator.ValidateAsync(dto);
            if (!validation.IsValid)
                throw new ValidationFailedException(validation.Errors.Select(error => new FieldError(error.PropertyName, error.ErrorMessage)).ToList());

            var result = await _service.Edit(id, dto, GetUserId());
            return Ok(result);
        }

        /// <summary>Deletes a report owned by the authenticated user.</summary>
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
