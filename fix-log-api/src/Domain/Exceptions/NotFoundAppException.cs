namespace fix_log_api.Domain.Exceptions
{
    public sealed class NotFoundAppException(string code, string message) : AppException(code, message)
    {
    }
}
