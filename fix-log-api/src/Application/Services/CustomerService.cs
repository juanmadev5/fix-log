using fix_log_api.Application.Common;
using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace fix_log_api.Application.Services
{
    public class CustomerService(ICustomerRepository repository, ILogger<CustomerService> logger) : ICustomerService
    {
        private readonly ICustomerRepository _repository = repository;
        private readonly ILogger<CustomerService> _logger = logger;

        public async Task<ResponseCustomerDto> Create(CreateCustomerDto dto, int userId)
        {
            var customer = new Customer
            {
                Id = 0,
                UserId = userId,
                Name = dto.Name,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber,
                Reports = []
            };

            await _repository.Create(customer);
            _logger.LogInformation("Customer {CustomerId} created for user {UserId}", customer.Id, userId);

            return ToDto(customer);
        }

        public async Task Delete(int id, int userId)
        {
            var deleted = await _repository.Delete(id, userId);
            if (!deleted)
                throw new NotFoundAppException("CUSTOMER_NOT_FOUND", $"Customer {id} was not found.");

            _logger.LogInformation("Customer {CustomerId} deleted for user {UserId}", id, userId);
        }

        public async Task<ResponseCustomerDto> Edit(int id, CreateCustomerDto dto, int userId)
        {
            var customer = new Customer
            {
                Id = id,
                UserId = userId,
                Name = dto.Name,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber,
                Reports = []
            };

            var updated = await _repository.Edit(customer);
            if (!updated)
                throw new NotFoundAppException("CUSTOMER_NOT_FOUND", $"Customer {id} was not found.");

            return ToDto(customer);
        }

        public async Task<PagedResult<ResponseCustomerDto>> GetAll(int userId, int page, int pageSize)
        {
            (page, pageSize) = PaginationDefaults.Normalize(page, pageSize);

            var (customers, totalCount) = await _repository.GetAll(userId, page, pageSize);
            var items = customers.Select(ToDto).ToList();

            return new PagedResult<ResponseCustomerDto>(items, page, pageSize, totalCount);
        }

        public async Task<ResponseCustomerDto> GetById(int id, int userId)
        {
            var customer = await _repository.GetById(id, userId)
                ?? throw new NotFoundAppException("CUSTOMER_NOT_FOUND", $"Customer {id} was not found.");

            return ToDto(customer);
        }

        private static ResponseCustomerDto ToDto(Customer customer) => new(
            customer.Id,
            customer.Name,
            customer.Email,
            customer.PhoneNumber,
            customer.Reports?.Select(report => new ResponseReportDto(
                report.Id, report.CustomerId, report.Date, report.Details, report.IsCompleted, report.IsPaid, report.Cost)).ToList() ?? []
        );
    }
}
