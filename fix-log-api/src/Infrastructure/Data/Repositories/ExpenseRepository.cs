using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace fix_log_api.Infrastructure.Data.Repositories
{
    public class ExpenseRepository(AppDbContext context) : IExpenseRepository
    {
        private readonly AppDbContext _context = context;

        public async Task Create(Expense entity)
        {
            await _context.AddAsync(entity);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> Delete(int id, int userId)
        {
            int rowsAffected = await _context.Set<Expense>()
                .Where(expense => expense.Id == id && expense.UserId == userId)
                .ExecuteDeleteAsync();

            return rowsAffected > 0;
        }

        public async Task<bool> Edit(Expense entity)
        {
            int rowsAffected = await _context
                .Set<Expense>()
                .Where(expense => expense.Id == entity.Id && expense.UserId == entity.UserId)
                .ExecuteUpdateAsync(setters =>
                    setters
                        .SetProperty(expense => expense.Title, entity.Title)
                        .SetProperty(expense => expense.Details, entity.Details)
                        .SetProperty(expense => expense.Price, entity.Price)
                        .SetProperty(expense => expense.Quantity, entity.Quantity)
                );

            return rowsAffected > 0;
        }

        public async Task<(List<Expense> Items, int TotalCount)> GetAll(int userId, int page, int pageSize)
        {
            var query = _context.Set<Expense>().Where(expense => expense.UserId == userId);

            int totalCount = await query.CountAsync();

            List<Expense> items = await query
                .OrderBy(expense => expense.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (items, totalCount);
        }

        public async Task<Expense?> GetById(int id, int userId)
        {
            return await _context.Set<Expense>()
                .FirstOrDefaultAsync(expense => expense.Id == id && expense.UserId == userId);
        }
    }
}
