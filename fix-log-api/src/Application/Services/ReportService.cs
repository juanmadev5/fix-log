using fix_log_api.Application.Common;
using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace fix_log_api.Application.Services
{
    public class ReportService(IReportRepository repository, ICustomerRepository customerRepository, ILogger<ReportService> logger) : IReportService
    {
        private readonly IReportRepository _repository = repository;
        private readonly ICustomerRepository _customerRepository = customerRepository;
        private readonly ILogger<ReportService> _logger = logger;

        public async Task<ResponseReportDto> Create(CreateReportDto dto, int userId)
        {
            await EnsureCustomerOwnedByUser(dto.CustomerId, userId);

            var report = new Report
            {
                UserId = userId,
                CustomerId = dto.CustomerId,
                Date = DateTime.SpecifyKind(dto.Date, DateTimeKind.Utc),
                Details = dto.Details,
                IsCompleted = dto.IsCompleted,
                IsPaid = dto.IsPaid,
                Cost = dto.Cost,
            };

            await _repository.Create(report);
            _logger.LogInformation("Report {ReportId} created for user {UserId}", report.Id, userId);

            return ToDto(report);
        }

        public async Task Delete(int id, int userId)
        {
            var deleted = await _repository.Delete(id, userId);
            if (!deleted)
                throw new NotFoundAppException("REPORT_NOT_FOUND", $"Report {id} was not found.");

            _logger.LogInformation("Report {ReportId} deleted for user {UserId}", id, userId);
        }

        public async Task<ResponseReportDto> Edit(int id, CreateReportDto dto, int userId)
        {
            await EnsureCustomerOwnedByUser(dto.CustomerId, userId);

            var report = new Report
            {
                Id = id,
                UserId = userId,
                CustomerId = dto.CustomerId,
                Date = DateTime.SpecifyKind(dto.Date, DateTimeKind.Utc),
                Details = dto.Details,
                IsCompleted = dto.IsCompleted,
                IsPaid = dto.IsPaid,
                Cost = dto.Cost,
            };

            var updated = await _repository.Edit(report);
            if (!updated)
                throw new NotFoundAppException("REPORT_NOT_FOUND", $"Report {id} was not found.");

            return ToDto(report);
        }

        public async Task<PagedResult<ResponseReportDto>> GetAll(int userId, int page, int pageSize)
        {
            (page, pageSize) = PaginationDefaults.Normalize(page, pageSize);

            var (reports, totalCount) = await _repository.GetAll(userId, page, pageSize);
            var items = reports.Select(ToDto).ToList();

            return new PagedResult<ResponseReportDto>(items, page, pageSize, totalCount);
        }

        public async Task<ResponseReportDto> GetById(int id, int userId)
        {
            var report = await _repository.GetById(id, userId)
                ?? throw new NotFoundAppException("REPORT_NOT_FOUND", $"Report {id} was not found.");

            return ToDto(report);
        }

        private async Task EnsureCustomerOwnedByUser(int customerId, int userId)
        {
            var customer = await _customerRepository.GetById(customerId, userId);
            if (customer == null)
                throw new NotFoundAppException("CUSTOMER_NOT_FOUND", $"Customer {customerId} was not found.");
        }

        private static ResponseReportDto ToDto(Report report) => new(
            report.Id, report.CustomerId, report.Date, report.Details, report.IsCompleted, report.IsPaid, report.Cost);
    }
}
