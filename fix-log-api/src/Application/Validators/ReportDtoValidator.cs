using fix_log_api.Application.DTOs;
using FluentValidation;

namespace fix_log_api.Application.Validators
{
    public class ReportDtoValidator : AbstractValidator<CreateReportDto>
    {
        public ReportDtoValidator()
        {
            RuleFor(dto => dto.CustomerId).InclusiveBetween(1, int.MaxValue);
            RuleFor(dto => dto.Details).NotEmpty();
            RuleFor(dto => dto.Cost).InclusiveBetween(0m, decimal.MaxValue);
        }
    }
}
