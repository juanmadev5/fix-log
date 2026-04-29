namespace fix_log_api.Domain.Common
{
    public record ActionResponse<T>(T? Response, string Message, Status Status);
}
