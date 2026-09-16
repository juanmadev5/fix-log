using fix_log_api.Application.Common;
using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace fix_log_api.Application.Services
{
    public class ExpenseService(IExpenseRepository repository, ILogger<ExpenseService> logger) : IExpenseService
    {
        private readonly IExpenseRepository _repository = repository;
        private readonly ILogger<ExpenseService> _logger = logger;

        public async Task<ResponseExpenseDto> Create(CreateExpenseDto dto, int userId)
        {
            var expense = new Expense
            {
                UserId = userId,
                Title = dto.Title,
                Details = dto.Details,
                Price = dto.Price,
                Quantity = dto.Quantity,
            };

            await _repository.Create(expense);
            _logger.LogInformation("Expense {ExpenseId} created for user {UserId}", expense.Id, userId);

            return ToDto(expense);
        }

        public async Task Delete(int id, int userId)
        {
            var deleted = await _repository.Delete(id, userId);
            if (!deleted)
                throw new NotFoundAppException("EXPENSE_NOT_FOUND", $"Expense {id} was not found.");

            _logger.LogInformation("Expense {ExpenseId} deleted for user {UserId}", id, userId);
        }

        public async Task<ResponseExpenseDto> Edit(int id, CreateExpenseDto dto, int userId)
        {
            var expense = new Expense
            {
                Id = id,
                UserId = userId,
                Title = dto.Title,
                Details = dto.Details,
                Price = dto.Price,
                Quantity = dto.Quantity,
            };

            var updated = await _repository.Edit(expense);
            if (!updated)
                throw new NotFoundAppException("EXPENSE_NOT_FOUND", $"Expense {id} was not found.");

            return ToDto(expense);
        }

        public async Task<PagedResult<ResponseExpenseDto>> GetAll(int userId, int page, int pageSize)
        {
            (page, pageSize) = PaginationDefaults.Normalize(page, pageSize);

            var (expenses, totalCount) = await _repository.GetAll(userId, page, pageSize);
            var items = expenses.Select(ToDto).ToList();

            return new PagedResult<ResponseExpenseDto>(items, page, pageSize, totalCount);
        }

        public async Task<ResponseExpenseDto> GetById(int id, int userId)
        {
            var expense = await _repository.GetById(id, userId)
                ?? throw new NotFoundAppException("EXPENSE_NOT_FOUND", $"Expense {id} was not found.");

            return ToDto(expense);
        }

        private static ResponseExpenseDto ToDto(Expense expense) =>
            new(expense.Id, expense.Title, expense.Details, expense.Price, expense.Quantity);
    }
}
