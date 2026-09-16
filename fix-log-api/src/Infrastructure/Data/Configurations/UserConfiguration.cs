using fix_log_api.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace fix_log_api.Infraestructure.Data.Configurations
{
    public class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            builder.ToTable("users");

            builder.Property(user => user.Id).HasColumnName("id");
            builder.Property(user => user.Email).HasColumnName("email");
            builder.Property(user => user.PasswordHash).HasColumnName("password_hash");

            builder.HasIndex(user => user.Email).IsUnique();
        }
    }
}
