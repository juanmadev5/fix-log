namespace fix_log_api.Domain.Exceptions
{
    public sealed class InvalidCredentialsException()
        : AppException("INVALID_CREDENTIALS", "The email or password is incorrect.")
    {
    }
}
