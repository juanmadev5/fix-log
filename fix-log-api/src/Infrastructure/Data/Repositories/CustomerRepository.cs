using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace fix_log_api.Infrastructure.Data.Repositories
{
    public class CustomerRepository(AppDbContext context) : ICustomerRepository
    {
        private readonly AppDbContext _context = context;

        public async Task Create(Customer entity)
        {
            await _context.AddAsync(entity);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> Delete(int id, int userId)
        {
            int rowsAffected = await _context.Set<Customer>()
                .Where(customer => customer.Id == id && customer.UserId == userId)
                .ExecuteDeleteAsync();

            return rowsAffected > 0;
        }

        public async Task<bool> Edit(Customer entity)
        {
            int rowsAffected = await _context
                .Set<Customer>()
                .Where(customer => customer.Id == entity.Id && customer.UserId == entity.UserId)
                .ExecuteUpdateAsync(setters =>
                    setters
                        .SetProperty(customer => customer.Name, entity.Name)
                        .SetProperty(customer => customer.Email, entity.Email)
                        .SetProperty(customer => customer.PhoneNumber, entity.PhoneNumber)
                );

            return rowsAffected > 0;
        }

        public async Task<(List<Customer> Items, int TotalCount)> GetAll(int userId, int page, int pageSize)
        {
            var query = _context.Set<Customer>().Where(customer => customer.UserId == userId);

            int totalCount = await query.CountAsync();

            List<Customer> items = await query
                .OrderBy(customer => customer.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Include(customer => customer.Reports)
                .ToListAsync();

            return (items, totalCount);
        }

        public async Task<Customer?> GetById(int id, int userId)
        {
            return await _context.Set<Customer>()
                .Include(customer => customer.Reports)
                .FirstOrDefaultAsync(customer => customer.Id == id && customer.UserId == userId);
        }
    }
}
