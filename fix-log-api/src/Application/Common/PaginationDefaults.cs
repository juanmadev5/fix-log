namespace fix_log_api.Application.Common
{
    public static class PaginationDefaults
    {
        public const int DefaultPage = 1;
        public const int DefaultPageSize = 20;
        public const int MaxPageSize = 100;

        public static (int Page, int PageSize) Normalize(int page, int pageSize) =>
            (Math.Max(DefaultPage, page), Math.Clamp(pageSize, 1, MaxPageSize));
    }
}
