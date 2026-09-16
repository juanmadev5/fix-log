namespace fix_log_api.Domain.Interfaces
{
    public interface ICommonActions<T>
        where T : class
    {
        Task<(List<T> Items, int TotalCount)> GetAll(int userId, int page, int pageSize);

        Task<T?> GetById(int id, int userId);

        Task Create(T entity);

        Task<bool> Edit(T entity);

        Task<bool> Delete(int id, int userId);
    }
}
