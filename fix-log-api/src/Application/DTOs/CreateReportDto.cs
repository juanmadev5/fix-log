using System.ComponentModel.DataAnnotations;

namespace fix_log_api.Application.DTOs
{
    public record CreateReportDto(
        [Range(1, int.MaxValue)] int CustomerId,
        [Required] DateTime Date,
        [Required] string Details,
        bool IsCompleted,
        bool IsPaid,
        [Range(0, double.MaxValue)] decimal Cost
    );
}
