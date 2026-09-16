using fix_log_api.Application.DTOs;
using FluentValidation;

namespace fix_log_api.Application.Validators
{
    public class CustomerDtoValidator : AbstractValidator<CreateCustomerDto>
    {
        public CustomerDtoValidator()
        {
            RuleFor(dto => dto.Name).NotEmpty().MaximumLength(100);
            RuleFor(dto => dto.Email).NotEmpty().EmailAddress();
            RuleFor(dto => dto.PhoneNumber).NotEmpty().MaximumLength(20);
        }
    }
}
