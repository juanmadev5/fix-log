using fix_log_api.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace fix_log_api.Infraestructure.Data.Configurations
{
    // DbUp's SQL scripts (db/migration/) are the real source of truth for the schema.
    // This Fluent config, including check constraints, is documentation that must stay in sync with them.
    public class CustomerConfiguration : IEntityTypeConfiguration<Customer>
    {
        public void Configure(EntityTypeBuilder<Customer> builder)
        {
            builder.ToTable("customers");

            builder.Property(customer => customer.Id).HasColumnName("id");
            builder.Property(customer => customer.UserId).HasColumnName("user_id");
            builder.Property(customer => customer.Name).HasColumnName("name");
            builder.Property(customer => customer.Email).HasColumnName("email");
            builder.Property(customer => customer.PhoneNumber).HasColumnName("phone_number");
            builder.Property(customer => customer.CreatedAt).HasColumnName("created_at");
            builder.Property(customer => customer.UpdatedAt).HasColumnName("updated_at");

            builder.HasIndex(customer => customer.UserId);

            builder.HasMany(customer => customer.Reports)
                .WithOne()
                .HasForeignKey(report => report.CustomerId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
