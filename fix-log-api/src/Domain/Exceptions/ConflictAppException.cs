namespace fix_log_api.Domain.Exceptions
{
    public sealed class ConflictAppException(string code, string message) : AppException(code, message)
    {
    }
}
