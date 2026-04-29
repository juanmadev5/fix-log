namespace fix_log_api.Application.DTOs
{
    public record CreateExpenseDto(string Title, string Details, float Price, int Quantity);
}
