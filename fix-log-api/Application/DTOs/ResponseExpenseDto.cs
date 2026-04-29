namespace fix_log_api.Application.DTOs
{
    public record ResponseExpenseDto(int Id, string Title, string Details, float Price, int Quantity);
}
