namespace fix_log_api.Application.DTOs
{
    public record CreateReportDto(int CustomerId, DateTime Date, string Details, bool IsCompleted, bool IsPaid);
}
