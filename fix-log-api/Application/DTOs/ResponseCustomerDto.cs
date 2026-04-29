namespace fix_log_api.Application.DTOs
{
    public record ResponseCustomerDto(int Id, string Name, string Email, string PhoneNumber, List<ResponseReportDto> Reports);
}
