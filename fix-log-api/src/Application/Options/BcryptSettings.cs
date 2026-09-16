namespace fix_log_api.Application.Options
{
    public class BcryptSettings
    {
        public const string SectionName = "BcryptSettings";

        public int WorkFactor { get; set; } = 12;
    }
}
