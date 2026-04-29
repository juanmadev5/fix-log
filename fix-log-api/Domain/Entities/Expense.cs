namespace fix_log_api.Domain.Entities
{
    public class Expense
    {
        public int Id { get; set; }
        public required string Title { get; set; }

        public required string Details { get; set; }

        public required float Price { get; set; }

        public required int Quantity { get; set; }
    }
}
