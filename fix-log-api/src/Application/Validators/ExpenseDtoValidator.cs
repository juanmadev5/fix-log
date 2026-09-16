using fix_log_api.Application.DTOs;
using FluentValidation;

namespace fix_log_api.Application.Validators
{
    public class ExpenseDtoValidator : AbstractValidator<CreateExpenseDto>
    {
        public ExpenseDtoValidator()
        {
            RuleFor(dto => dto.Title).NotEmpty().MaximumLength(100);
            RuleFor(dto => dto.Details).NotEmpty();
            RuleFor(dto => dto.Price).InclusiveBetween(0.01f, float.MaxValue);
            RuleFor(dto => dto.Quantity).InclusiveBetween(1, int.MaxValue);
        }
    }
}
