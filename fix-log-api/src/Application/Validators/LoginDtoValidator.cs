using fix_log_api.Application.DTOs;
using FluentValidation;

namespace fix_log_api.Application.Validators
{
    public class LoginDtoValidator : AbstractValidator<LoginDto>
    {
        public LoginDtoValidator()
        {
            RuleFor(dto => dto.Email).NotEmpty().EmailAddress();
            RuleFor(dto => dto.Password).NotEmpty();
        }
    }
}
