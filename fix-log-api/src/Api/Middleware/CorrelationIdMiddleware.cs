using Serilog.Context;

namespace fix_log_api.Api.Middleware
{
    public sealed class CorrelationIdMiddleware(RequestDelegate next)
    {
        private const string HeaderName = "X-Correlation-Id";

        public async Task InvokeAsync(HttpContext context)
        {
            var correlationId = context.Request.Headers.TryGetValue(HeaderName, out var existing) && !string.IsNullOrWhiteSpace(existing)
                ? existing.ToString()
                : Guid.NewGuid().ToString();

            // Set via OnStarting, not directly: the exception-handling middleware resets the
            // response (clearing headers already set here) before an IExceptionHandler writes an
            // error body, so an immediate assignment is silently lost on every error response.
            // OnStarting runs right before headers are actually sent, after that reset.
            context.Response.OnStarting(() =>
            {
                context.Response.Headers[HeaderName] = correlationId;
                return Task.CompletedTask;
            });

            using (LogContext.PushProperty("CorrelationId", correlationId))
            {
                await next(context);
            }
        }
    }
}
