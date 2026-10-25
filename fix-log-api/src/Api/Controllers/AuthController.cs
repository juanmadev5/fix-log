using Asp.Versioning;
using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace fix_log_api.Api.Controllers
{
    /// <summary>Registration and login for the authenticated user account.</summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [EnableRateLimiting("auth")]
    public class AuthController(IAuthService service, IValidator<RegisterDto> registerValidator, IValidator<LoginDto> loginValidator) : ControllerBase
    {
        private readonly IAuthService _service = service;
        private readonly IValidator<RegisterDto> _registerValidator = registerValidator;
        private readonly IValidator<LoginDto> _loginValidator = loginValidator;

        /// <summary>Creates a new user account.</summary>
        [HttpPost("register")]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            var validation = await _registerValidator.ValidateAsync(dto);
            validation.ThrowIfInvalid();

            var result = await _service.Register(dto);
            return Ok(result);
        }

        /// <summary>Authenticates a user and issues a JWT.</summary>
        [HttpPost("login")]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var validation = await _loginValidator.ValidateAsync(dto);
            validation.ThrowIfInvalid();

            var result = await _service.Login(dto);
            return Ok(result);
        }
    }
}
