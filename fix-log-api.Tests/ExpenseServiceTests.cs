using fix_log_api.Application.DTOs;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;

namespace fix_log_api.Tests;

public class ExpenseServiceTests
{
    private readonly Mock<IExpenseRepository> _repo = new();
    private readonly ExpenseService _service;

    public ExpenseServiceTests()
    {
        _service = new ExpenseService(_repo.Object, NullLogger<ExpenseService>.Instance);
    }

    [Fact]
    public async Task Given_ValidData_When_Creating_Then_ReturnsCreatedExpense()
    {
        // Given
        _repo.Setup(repository => repository.Create(It.IsAny<Expense>())).Returns(Task.CompletedTask);

        // When
        var result = await _service.Create(new CreateExpenseDto("Gasolina", "Combustible", 50000f, 1), userId: 1);

        // Then
        Assert.NotNull(result);
    }

    [Fact]
    public async Task Given_OwnedExpense_When_Editing_Then_ReturnsUpdatedExpense()
    {
        // Given
        _repo.Setup(repository => repository.Edit(It.IsAny<Expense>())).ReturnsAsync(true);

        var dto = new CreateExpenseDto("Gasolina Premium", "Combustible full", 60000f, 1);

        // When
        var result = await _service.Edit(1, dto, userId: 1);

        // Then
        Assert.Equal("Gasolina Premium", result.Title);
    }

    [Fact]
    public async Task Given_ExpenseOwnedByAnotherUser_When_Editing_Then_ThrowsNotFoundAppException()
    {
        // Given
        _repo.Setup(repository => repository.Edit(It.IsAny<Expense>())).ReturnsAsync(false);

        var dto = new CreateExpenseDto("Gasolina Premium", "Combustible full", 60000f, 1);

        // When
        var act = () => _service.Edit(1, dto, userId: 99);

        // Then
        await Assert.ThrowsAsync<NotFoundAppException>(act);
    }

    [Fact]
    public async Task Given_NoExpenses_When_GettingAll_Then_ReturnsEmptyList()
    {
        // Given
        _repo.Setup(repository => repository.GetAll(1, It.IsAny<int>(), It.IsAny<int>())).ReturnsAsync(([], 0));

        // When
        var result = await _service.GetAll(1, 1, 20);

        // Then
        Assert.Empty(result.Items);
    }

    [Fact]
    public async Task Given_ExpenseOwnedByAnotherUser_When_Deleting_Then_ThrowsNotFoundAppException()
    {
        // Given
        _repo.Setup(repository => repository.Delete(1, 99)).ReturnsAsync(false);

        // When
        var act = () => _service.Delete(1, userId: 99);

        // Then
        await Assert.ThrowsAsync<NotFoundAppException>(act);
    }
}
