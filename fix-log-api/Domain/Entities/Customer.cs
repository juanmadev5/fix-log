namespace fix_log_api.Domain.Entities
{
    public class Customer
    {

        public required int Id { get; set; }

        public required int UserId { get; set; }

        public required string Name { get; set; }

        public required string Email { get; set; }

        public required string PhoneNumber { get; set; }

        public required List<Report> Reports { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }
    }
}
