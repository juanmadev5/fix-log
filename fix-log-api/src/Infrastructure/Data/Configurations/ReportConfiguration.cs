using fix_log_api.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace fix_log_api.Infraestructure.Data.Configurations
{
    // DbUp's SQL scripts (db/migration/) are the real source of truth for the schema.
    // This Fluent config, including check constraints, is documentation that must stay in sync with them.
    public class ReportConfiguration : IEntityTypeConfiguration<Report>
    {
        public void Configure(EntityTypeBuilder<Report> builder)
        {
            builder.ToTable("reports", t => t.HasCheckConstraint("CK_reports_cost", "cost >= 0"));

            builder.Property(report => report.Id).HasColumnName("id");
            builder.Property(report => report.UserId).HasColumnName("user_id");
            builder.Property(report => report.CustomerId).HasColumnName("customer_id");
            builder.Property(report => report.Date).HasColumnName("date");
            builder.Property(report => report.Details).HasColumnName("details");
            builder.Property(report => report.IsCompleted).HasColumnName("is_completed");
            builder.Property(report => report.IsPaid).HasColumnName("is_paid");
            builder.Property(report => report.Cost).HasColumnName("cost");
            builder.Property(report => report.CreatedAt).HasColumnName("created_at");
            builder.Property(report => report.UpdatedAt).HasColumnName("updated_at");

            // CustomerId's index comes from CustomerConfiguration's HasForeignKey (EF Core auto-indexes FK columns).
            builder.HasIndex(report => report.UserId);
        }
    }
}
