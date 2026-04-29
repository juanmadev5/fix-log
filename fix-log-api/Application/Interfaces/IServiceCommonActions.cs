using fix_log_api.Domain.Common;

namespace fix_log_api.Application.Interfaces
{
    public interface IServiceCommonActions<TResponse, TRequest>
        where TResponse : class
        where TRequest : class
    {
        Task<ActionResponse<List<TResponse>?>> GetAll();
        Task<ActionResponse<TResponse?>> GetById(int id);
        Task<ActionResponse<TResponse>> Create(TRequest dto);
        Task<ActionResponse<TResponse>> Edit(TResponse dto);
        Task<ActionResponse<bool>> Delete(int id);
    }
}
