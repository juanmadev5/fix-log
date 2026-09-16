using fix_log_api.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace fix_log_api.Infraestructure.Data.Configurations
{
    // DbUp's SQL scripts (db/migration/) are the real source of truth for the schema.
    // This Fluent config, including check constraints, is documentation that must stay in sync with them.
    public class ExpenseConfiguration : IEntityTypeConfiguration<Expense>
    {
        public void Configure(EntityTypeBuilder<Expense> builder)
        {
            builder.ToTable("expenses", t =>
            {
                t.HasCheckConstraint("CK_expenses_price", "price > 0");
                t.HasCheckConstraint("CK_expenses_quantity", "quantity > 0");
            });

            builder.Property(expense => expense.Id).HasColumnName("id");
            builder.Property(expense => expense.UserId).HasColumnName("user_id");
            builder.Property(expense => expense.Title).HasColumnName("title");
            builder.Property(expense => expense.Details).HasColumnName("details");
            builder.Property(expense => expense.Price).HasColumnName("price");
            builder.Property(expense => expense.Quantity).HasColumnName("quantity");
            builder.Property(expense => expense.CreatedAt).HasColumnName("created_at");
            builder.Property(expense => expense.UpdatedAt).HasColumnName("updated_at");

            builder.HasIndex(expense => expense.UserId);
        }
    }
}
