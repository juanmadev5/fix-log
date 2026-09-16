using fix_log_api.Application.Common;

namespace fix_log_api.Application.Interfaces
{
    public interface IServiceCommonActions<TResponse, TRequest>
        where TResponse : class
        where TRequest : class
    {
        Task<PagedResult<TResponse>> GetAll(int userId, int page, int pageSize);
        Task<TResponse> GetById(int id, int userId);
        Task<TResponse> Create(TRequest dto, int userId);
        Task<TResponse> Edit(int id, TRequest dto, int userId);
        Task Delete(int id, int userId);
    }
}
