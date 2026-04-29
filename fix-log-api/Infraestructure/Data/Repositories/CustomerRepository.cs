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
                .Where(r => r.Id == entity.Id)
                .ExecuteUpdateAsync(setters =>
                    setters
                        .SetProperty(r => r.Name, r => entity.Name)
                        .SetProperty(r => r.Email, r => entity.Email)
                        .SetProperty(r => r.PhoneNumber, r => entity.PhoneNumber)
                        .SetProperty(r => r.Reports, r => entity.Reports)
                );

            return rowsAffected > 0;
        }

        public async Task<List<Customer>?> GetAll()
        {
            return await _context.Set<Customer>().ToListAsync();
        }

        public async Task<Customer?> GetById(int id)
        {
            return await _context.Set<Customer>().FindAsync(id);
        }
    }
}
