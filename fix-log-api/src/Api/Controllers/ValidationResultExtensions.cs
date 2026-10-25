using fix_log_api.Domain.Exceptions;
using FluentValidation.Results;
using System.Text.Json;

namespace fix_log_api.Api.Controllers
{
    public static class ValidationResultExtensions
    {
        /// <summary>
        /// Throws a ValidationFailedException with each field name converted to the same
        /// snake_case wire format the rest of the API speaks - FluentValidation's PropertyName
        /// is the raw PascalCase C# property name and would otherwise leak that casing straight
        /// into the error response's "errors[].field" value.
        /// </summary>
        public static void ThrowIfInvalid(this ValidationResult validation)
        {
            if (validation.IsValid) return;

            throw new ValidationFailedException(validation.Errors
                .Select(error => new FieldError(JsonNamingPolicy.SnakeCaseLower.ConvertName(error.PropertyName), error.ErrorMessage))
                .ToList());
        }
    }
}
