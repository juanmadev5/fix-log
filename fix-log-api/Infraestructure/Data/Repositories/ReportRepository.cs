using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace fix_log_api.Infraestructure.Data.Repositories
{
    public class ReportRepository(AppDbContext context) : IReportRepository
    {
        private readonly AppDbContext _context = context;

        public async Task<List<Report>?> GetAll()
        {
            return await _context.Set<Report>().ToListAsync();
        }

        public async Task<Report?> GetById(int id)
        {
            return await _context.Set<Report>().FindAsync(id);
        }

        public async Task<bool> Create(Report entity)
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

        public async Task<bool> Edit(Report entity)
        {
            int rowsAffected = await _context
                .Set<Report>()
                .Where(r => r.Id == entity.Id)
                .ExecuteUpdateAsync(setters =>
                    setters
                        .SetProperty(r => r.Details, entity.Details)
                        .SetProperty(r => r.CustomerId, entity.CustomerId)
                        .SetProperty(r => r.Date, entity.Date)
                        .SetProperty(r => r.IsCompleted, entity.IsCompleted)
                        .SetProperty(r => r.IsPaid, entity.IsPaid)
                );

            return rowsAffected > 0;
        }

        public async Task<bool> Delete(int id)
        {
            Report? report = await _context.Set<Report>().FindAsync(id);

            if (report == null)
            {
                return false;
            }

            _context.Set<Report>().Remove(report);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
