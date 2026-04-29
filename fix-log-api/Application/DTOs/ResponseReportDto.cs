namespace fix_log_api.Application.DTOs
{
    public record ResponseReportDto(int Id, int CustomerId, DateTime Date, string Details, bool IsCompleted, bool IsPaid);
}
