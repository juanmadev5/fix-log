namespace fix_log_api.Domain.Interfaces
{
    public interface ICommonActions<T>
        where T : class
    {
        Task<List<T>?> GetAll();

        Task<T?> GetById(int id);

        Task<bool> Create(T entity);

        Task<bool> Edit(T entity);

        Task<bool> Delete(int id);
    }
}
