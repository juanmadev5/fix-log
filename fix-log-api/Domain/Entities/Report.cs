namespace fix_log_api.Domain.Entities
{
    public class Report
    {

        public int Id { get; set; }

        public required int CustomerId { get; set; }

        public required DateTime Date { get; set; }

        public required string Details { get; set; }

        public required bool IsCompleted { get; set; }

        public required bool IsPaid { get; set; }
    }
}
