namespace fix_log_api.Domain.Common
{
    public record PagedResult<T>(List<T> Items, int Page, int PageSize, int TotalCount);
}
