using fix_log_api.Application.DTOs;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Moq;

namespace fix_log_api.Tests;

public class CustomerServiceTests
{
    private readonly Mock<ICustomerRepository> _repo = new();
    private readonly CustomerService _service;

    public CustomerServiceTests()
    {
        _service = new CustomerService(_repo.Object);
    }

    [Fact]
    public async Task GetAll_WithExistingCustomers_ReturnsSuccess()
    {
        _repo.Setup(r => r.GetAll(1)).ReturnsAsync(
        [
            new() { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] }
        ]);

        var result = await _service.GetAll(1);

        Assert.Equal(Status.SUCCESS, result.Status);
        Assert.Single(result.Response!);
    }

    [Fact]
    public async Task GetAll_WhenEmpty_ReturnsNotFound()
    {
        _repo.Setup(r => r.GetAll(1)).ReturnsAsync([]);

        var result = await _service.GetAll(1);

        Assert.Equal(Status.NOT_FOUND, result.Status);
    }

    [Fact]
    public async Task GetById_WithCorrectUser_ReturnsFound()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Customer { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] }
        );

        var result = await _service.GetById(1, userId: 1);

        Assert.Equal(Status.FOUND, result.Status);
    }

    [Fact]
    public async Task GetById_WithWrongUser_ReturnsNotFound()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Customer { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] }
        );

        var result = await _service.GetById(1, userId: 99);

        Assert.Equal(Status.NOT_FOUND, result.Status);
    }

    [Fact]
    public async Task Create_WithValidData_ReturnsSuccess()
    {
        _repo.Setup(r => r.Create(It.IsAny<Customer>())).ReturnsAsync(true);

        var result = await _service.Create(new CreateCustomerDto("Juan", "juan@test.com", "123"), userId: 1);

        Assert.Equal(Status.SUCCESS, result.Status);
    }

    [Fact]
    public async Task Delete_WithCorrectUser_ReturnsSuccess()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Customer { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] }
        );
        _repo.Setup(r => r.Delete(1)).ReturnsAsync(true);

        var result = await _service.Delete(1, userId: 1);

        Assert.Equal(Status.SUCCESS, result.Status);
    }

    [Fact]
    public async Task Delete_WithWrongUser_ReturnsNotFound_AndNeverCallsRepo()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Customer { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] }
        );

        var result = await _service.Delete(1, userId: 99);

        Assert.Equal(Status.NOT_FOUND, result.Status);
        _repo.Verify(r => r.Delete(It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task Edit_WithWrongUser_ReturnsNotFound_AndNeverCallsRepo()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Customer { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] }
        );

        var dto = new ResponseCustomerDto(1, "NuevoNombre", "nuevo@test.com", "999", []);
        var result = await _service.Edit(dto, userId: 99);

        Assert.Equal(Status.NOT_FOUND, result.Status);
        _repo.Verify(r => r.Edit(It.IsAny<Customer>()), Times.Never);
    }
}
