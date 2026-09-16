namespace fix_log_api.Domain.Exceptions
{
    public abstract class AppException(string code, string message) : Exception(message)
    {
        public string Code { get; } = code;
    }
}
