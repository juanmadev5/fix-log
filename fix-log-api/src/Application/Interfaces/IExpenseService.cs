using fix_log_api.Application.DTOs;

namespace fix_log_api.Application.Interfaces
{
    public interface IExpenseService : IServiceCommonActions<ResponseExpenseDto, CreateExpenseDto>
    {
    }
}
