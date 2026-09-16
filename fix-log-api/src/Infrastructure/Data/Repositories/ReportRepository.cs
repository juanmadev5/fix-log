using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace fix_log_api.Infrastructure.Data.Repositories
{
    public class ReportRepository(AppDbContext context) : IReportRepository
    {
        private readonly AppDbContext _context = context;

        public async Task<(List<Report> Items, int TotalCount)> GetAll(int userId, int page, int pageSize)
        {
            var query = _context.Set<Report>().Where(report => report.UserId == userId);

            int totalCount = await query.CountAsync();

            List<Report> items = await query
                .OrderBy(report => report.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (items, totalCount);
        }

        public async Task<Report?> GetById(int id, int userId)
        {
            return await _context.Set<Report>()
                .FirstOrDefaultAsync(report => report.Id == id && report.UserId == userId);
        }

        public async Task Create(Report entity)
        {
            await _context.AddAsync(entity);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> Edit(Report entity)
        {
            int rowsAffected = await _context
                .Set<Report>()
                .Where(report => report.Id == entity.Id && report.UserId == entity.UserId)
                .ExecuteUpdateAsync(setters =>
                    setters
                        .SetProperty(report => report.Details, entity.Details)
                        .SetProperty(report => report.CustomerId, entity.CustomerId)
                        .SetProperty(report => report.Date, entity.Date)
                        .SetProperty(report => report.IsCompleted, entity.IsCompleted)
                        .SetProperty(report => report.IsPaid, entity.IsPaid)
                        .SetProperty(report => report.Cost, entity.Cost)
                );

            return rowsAffected > 0;
        }

        public async Task<bool> Delete(int id, int userId)
        {
            int rowsAffected = await _context.Set<Report>()
                .Where(report => report.Id == id && report.UserId == userId)
                .ExecuteDeleteAsync();

            return rowsAffected > 0;
        }
    }
}
