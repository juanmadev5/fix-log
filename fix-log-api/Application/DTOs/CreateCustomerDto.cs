using System.ComponentModel.DataAnnotations;

namespace fix_log_api.Application.DTOs
{
    public record CreateCustomerDto(
        [Required][MaxLength(100)] string Name,
        [Required][EmailAddress] string Email,
        [Required][MaxLength(20)] string PhoneNumber
    );
}
