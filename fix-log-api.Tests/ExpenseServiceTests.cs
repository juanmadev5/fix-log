using fix_log_api.Application.DTOs;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Moq;

namespace fix_log_api.Tests;

public class ExpenseServiceTests
{
    private readonly Mock<IExpenseRepository> _repo = new();
    private readonly ExpenseService _service;

    public ExpenseServiceTests()
    {
        _service = new ExpenseService(_repo.Object);
    }

    [Fact]
    public async Task Create_WithValidData_ReturnsSuccess()
    {
        _repo.Setup(r => r.Create(It.IsAny<Expense>())).ReturnsAsync(true);

        var result = await _service.Create(new CreateExpenseDto("Gasolina", "Combustible", 50000f, 1), userId: 1);

        Assert.Equal(Status.SUCCESS, result.Status);
        Assert.NotNull(result.Response);
    }

    [Fact]
    public async Task Edit_WithCorrectUser_ReturnsSuccess()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Expense { Id = 1, UserId = 1, Title = "Gasolina", Details = "Combustible", Price = 50000f, Quantity = 1 }
        );
        _repo.Setup(r => r.Edit(It.IsAny<Expense>())).ReturnsAsync(true);

        var dto = new ResponseExpenseDto(1, "Gasolina Premium", "Combustible full", 60000f, 1);
        var result = await _service.Edit(dto, userId: 1);

        Assert.Equal(Status.SUCCESS, result.Status);
    }

    [Fact]
    public async Task Edit_WithWrongUser_ReturnsNotFound_AndNeverCallsRepo()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Expense { Id = 1, UserId = 1, Title = "Gasolina", Details = "Combustible", Price = 50000f, Quantity = 1 }
        );

        var dto = new ResponseExpenseDto(1, "Gasolina Premium", "Combustible full", 60000f, 1);
        var result = await _service.Edit(dto, userId: 99);

        Assert.Equal(Status.NOT_FOUND, result.Status);
        _repo.Verify(r => r.Edit(It.IsAny<Expense>()), Times.Never);
    }

    [Fact]
    public async Task GetAll_WhenEmpty_ReturnsNotFound()
    {
        _repo.Setup(r => r.GetAll(1)).ReturnsAsync([]);

        var result = await _service.GetAll(1);

        Assert.Equal(Status.NOT_FOUND, result.Status);
    }
}
