namespace fix_log_api.Domain.Exceptions
{
    public sealed record FieldError(string Field, string Message);

    public sealed class ValidationFailedException(IReadOnlyList<FieldError> errors)
        : AppException("VALIDATION_FAILED", "The request contains invalid fields.")
    {
        public IReadOnlyList<FieldError> Errors { get; } = errors;
    }
}
