using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace fix_log_api.Infraestructure.Data.Repositories
{
    public class CustomerRepository(AppDbContext context) : ICustomerRepository
    {
        private readonly AppDbContext _context = context;

        public async Task<bool> Create(Customer entity)
        {
            try
            {
                await _context.AddAsync(entity);
                await _context.SaveChangesAsync();
            }
            catch (Exception)
            {
                return false;
            }
            return true;
        }

        public async Task<bool> Delete(int id)
        {
            Customer? customer = await _context.Set<Customer>().FindAsync(id);

            if (customer == null)
            {
                return false;
            }

            _context.Set<Customer>().Remove(customer);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> Edit(Customer entity)
        {
            int rowsAffected = await _context
                .Set<Customer>()
                .Where(r => r.Id == entity.Id && r.UserId == entity.UserId)
                .ExecuteUpdateAsync(setters =>
                    setters
                        .SetProperty(r => r.Name, entity.Name)
                        .SetProperty(r => r.Email, entity.Email)
                        .SetProperty(r => r.PhoneNumber, entity.PhoneNumber)
                );

            return rowsAffected > 0;
        }

        public async Task<List<Customer>?> GetAll(int userId)
        {
            return await _context.Set<Customer>()
                .Where(c => c.UserId == userId)
                .Include(c => c.Reports)
                .ToListAsync();
        }

        public async Task<Customer?> GetById(int id)
        {
            return await _context.Set<Customer>()
                .Include(c => c.Reports)
                .FirstOrDefaultAsync(c => c.Id == id);
        }
    }
}
