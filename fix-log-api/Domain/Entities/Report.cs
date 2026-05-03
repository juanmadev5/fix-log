namespace fix_log_api.Domain.Entities
{
    public class Report
    {

        public int Id { get; set; }

        public required int UserId { get; set; }

        public required int CustomerId { get; set; }

        public required DateTime Date { get; set; }

        public required string Details { get; set; }

        public required bool IsCompleted { get; set; }

        public required bool IsPaid { get; set; }

        public decimal Cost { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }
    }
}
