using fix_log_api.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace fix_log_api.Infraestructure.Data
{
    public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
    {
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Expense> Expenses { get; set; }
        public DbSet<Report> Reports { get; set; }
        public DbSet<User> Users { get; set; }
    }
}
