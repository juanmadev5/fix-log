using fix_log_api.Domain.Exceptions;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace fix_log_api.Api.Middleware
{
    /// <summary>Maps every unhandled exception to a single, consistent RFC 7807 response shape.</summary>
    /// <remarks>
    /// Serializes via the same <see cref="JsonOptions"/> the controllers use (configured once in
    /// Program.cs) rather than letting <c>WriteAsJsonAsync</c> fall back to ASP.NET Core's own
    /// "web defaults" (camelCase) — <c>Microsoft.AspNetCore.Mvc.JsonOptions</c> only feeds MVC's
    /// formatters, it is not picked up automatically by a raw <c>HttpResponse.WriteAsJsonAsync</c> call.
    /// </remarks>
    public sealed class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger, IOptions<JsonOptions> jsonOptions) : IExceptionHandler
    {
        public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
        {
            var (statusCode, code) = MapException(exception);

            if (statusCode == StatusCodes.Status500InternalServerError)
            {
                logger.LogError(exception, "Unhandled exception for {Method} {Path}", httpContext.Request.Method, httpContext.Request.Path);
            }
            else
            {
                logger.LogWarning("Handled {Code} for {Method} {Path}: {Message}", code, httpContext.Request.Method, httpContext.Request.Path, exception.Message);
            }

            var problemDetails = new ProblemDetails
            {
                Status = statusCode,
                Title = code,
                Detail = statusCode == StatusCodes.Status500InternalServerError
                    ? "An unexpected error occurred."
                    : exception.Message,
            };
            problemDetails.Extensions["code"] = code;

            if (exception is ValidationFailedException validationException)
            {
                problemDetails.Extensions["errors"] = validationException.Errors;
            }

            httpContext.Response.StatusCode = statusCode;
            await httpContext.Response.WriteAsJsonAsync(problemDetails, jsonOptions.Value.JsonSerializerOptions, cancellationToken);

            return true;
        }

        private static (int StatusCode, string Code) MapException(Exception exception) => exception switch
        {
            NotFoundAppException ex => (StatusCodes.Status404NotFound, ex.Code),
            ConflictAppException ex => (StatusCodes.Status409Conflict, ex.Code),
            InvalidCredentialsException ex => (StatusCodes.Status401Unauthorized, ex.Code),
            ValidationFailedException ex => (StatusCodes.Status422UnprocessableEntity, ex.Code),
            _ => (StatusCodes.Status500InternalServerError, "INTERNAL_SERVER_ERROR"),
        };
    }
}
