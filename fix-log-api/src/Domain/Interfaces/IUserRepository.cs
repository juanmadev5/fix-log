using fix_log_api.Domain.Entities;

namespace fix_log_api.Domain.Interfaces
{
    public interface IUserRepository
    {
        Task<User?> GetByEmail(string email);
        Task Create(User user);
    }
}
