namespace fix_log_api.Domain.Entities
{
    public class User
    {
        public int Id { get; set; }
        public required string Email { get; set; }
        public required string PasswordHash { get; set; }
    }
}
