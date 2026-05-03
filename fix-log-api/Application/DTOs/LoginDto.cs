using System.ComponentModel.DataAnnotations;

namespace fix_log_api.Application.DTOs
{
    public record LoginDto(
        [Required][EmailAddress] string Email,
        [Required] string Password
    );
}
