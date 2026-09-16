using fix_log_api.Application.DTOs;

namespace fix_log_api.Application.Interfaces
{
    public interface IReportService : IServiceCommonActions<ResponseReportDto, CreateReportDto>
    {
    }
}
