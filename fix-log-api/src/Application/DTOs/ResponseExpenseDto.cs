using System.ComponentModel.DataAnnotations;

namespace fix_log_api.Application.DTOs
{
    public record ResponseExpenseDto(
        [Range(1, int.MaxValue)] int Id,
        [Required][MaxLength(100)] string Title,
        [Required] string Details,
        [Range(0.01, float.MaxValue)] float Price,
        [Range(1, int.MaxValue)] int Quantity
    );
}
