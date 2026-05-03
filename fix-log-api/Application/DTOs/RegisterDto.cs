using System.ComponentModel.DataAnnotations;

namespace fix_log_api.Application.DTOs
{
    public record RegisterDto(
        [Required][EmailAddress] string Email,
        [Required][MinLength(6)] string Password
    );
}
