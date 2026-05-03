using fix_log_api.Domain.Common;

namespace fix_log_api.Application.Interfaces
{
    public interface IServiceCommonActions<TResponse, TRequest>
        where TResponse : class
        where TRequest : class
    {
        Task<ActionResponse<List<TResponse>?>> GetAll(int userId);
        Task<ActionResponse<TResponse?>> GetById(int id, int userId);
        Task<ActionResponse<TResponse>> Create(TRequest dto, int userId);
        Task<ActionResponse<TResponse>> Edit(TResponse dto, int userId);
        Task<ActionResponse<bool>> Delete(int id, int userId);
    }
}
