using fix_log_api.Application.DTOs;
using FluentValidation;

namespace fix_log_api.Application.Validators
{
    public class RegisterDtoValidator : AbstractValidator<RegisterDto>
    {
        public RegisterDtoValidator()
        {
            RuleFor(dto => dto.Email).NotEmpty().EmailAddress();
            RuleFor(dto => dto.Password).NotEmpty().MinimumLength(6);
        }
    }
}
