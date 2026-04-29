using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace fix_log_api.Infraestructure.Data.Repositories
{
    public class ExpenseRepository(AppDbContext context) : IExpenseRepository
    {
        private readonly AppDbContext _context = context;

        public async Task<bool> Create(Expense entity)
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
            Expense? expense = await _context.Set<Expense>().FindAsync(id);

            if (expense == null)
            {
                return false;
            }

            _context.Set<Expense>().Remove(expense);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> Edit(Expense entity)
        {
            int rowsAffected = await _context
                .Set<Expense>()
                .Where(r => r.Id == entity.Id)
                .ExecuteUpdateAsync(setters =>
                    setters
                        .SetProperty(r => r.Title, r => entity.Title)
                        .SetProperty(r => r.Details, entity.Details)
                        .SetProperty(r => r.Price, r => entity.Price)
                        .SetProperty(r => r.Quantity, r => entity.Quantity)
                );

            return rowsAffected > 0;
        }

        public async Task<List<Expense>?> GetAll()
        {
            return await _context.Set<Expense>().ToListAsync();
        }

        public async Task<Expense?> GetById(int id)
        {
            return await _context.Set<Expense>().FindAsync(id);
        }
    }
}
