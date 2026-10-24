using fix_log_api.Application.DTOs;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;

namespace fix_log_api.Tests;

public class CustomerServiceTests
{
    private readonly Mock<ICustomerRepository> _repo = new();
    private readonly CustomerService _service;

    public CustomerServiceTests()
    {
        _service = new CustomerService(_repo.Object, NullLogger<CustomerService>.Instance);
    }

    [Fact]
    public async Task Given_ExistingCustomers_When_GettingAll_Then_ReturnsThem()
    {
        // Given
        _repo.Setup(repository => repository.GetAll(1, It.IsAny<int>(), It.IsAny<int>())).ReturnsAsync(
        ([
            new() { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] }
        ], 1));

        // When
        var result = await _service.GetAll(1, 1, 20);

        // Then
        Assert.Single(result.Items);
    }

    [Fact]
    public async Task Given_NoCustomers_When_GettingAll_Then_ReturnsEmptyList()
    {
        // Given
        _repo.Setup(repository => repository.GetAll(1, It.IsAny<int>(), It.IsAny<int>())).ReturnsAsync(([], 0));

        // When
        var result = await _service.GetAll(1, 1, 20);

        // Then
        Assert.Empty(result.Items);
    }

    [Fact]
    public async Task Given_PageSizeAboveMax_When_GettingAll_Then_ClampsToMax()
    {
        // Given
        _repo.Setup(repository => repository.GetAll(1, 1, 100)).ReturnsAsync(([], 0));

        // When
        var result = await _service.GetAll(1, 1, 1000);

        // Then
        Assert.Equal(100, result.PageSize);
        _repo.Verify(repository => repository.GetAll(1, 1, 100), Times.Once);
    }

    [Fact]
    public async Task Given_PageBelowOne_When_GettingAll_Then_ClampsToOne()
    {
        // Given
        _repo.Setup(repository => repository.GetAll(1, 1, 20)).ReturnsAsync(([], 0));

        // When
        var result = await _service.GetAll(1, 0, 20);

        // Then
        Assert.Equal(1, result.Page);
        _repo.Verify(repository => repository.GetAll(1, 1, 20), Times.Once);
    }

    [Fact]
    public async Task Given_OwnedCustomer_When_GettingById_Then_ReturnsIt()
    {
        // Given
        _repo.Setup(repository => repository.GetById(1, 1)).ReturnsAsync(
            new Customer { Id = 1, UserId = 1, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] });

        // When
        var result = await _service.GetById(1, userId: 1);

        // Then
        Assert.Equal(1, result.Id);
    }

    [Fact]
    public async Task Given_CustomerOwnedByAnotherUser_When_GettingById_Then_ThrowsNotFoundAppException()
    {
        // Given
        _repo.Setup(repository => repository.GetById(1, 99)).ReturnsAsync((Customer?)null);

        // When
        var act = () => _service.GetById(1, userId: 99);

        // Then
        await Assert.ThrowsAsync<NotFoundAppException>(act);
    }

    [Fact]
    public async Task Given_ValidData_When_Creating_Then_ReturnsCreatedCustomer()
    {
        // Given
        _repo.Setup(repository => repository.Create(It.IsAny<Customer>())).Returns(Task.CompletedTask);

        // When
        var result = await _service.Create(new CreateCustomerDto("Juan", "juan@test.com", "123"), userId: 1);

        // Then
        Assert.Equal("Juan", result.Name);
    }

    [Fact]
    public async Task Given_OwnedCustomer_When_Deleting_Then_Succeeds()
    {
        // Given
        _repo.Setup(repository => repository.Delete(1, 1)).ReturnsAsync(true);

        // When
        var act = () => _service.Delete(1, userId: 1);

        // Then
        await act();
    }

    [Fact]
    public async Task Given_CustomerOwnedByAnotherUser_When_Deleting_Then_ThrowsNotFoundAppException()
    {
        // Given
        _repo.Setup(repository => repository.Delete(1, 99)).ReturnsAsync(false);

        // When
        var act = () => _service.Delete(1, userId: 99);

        // Then
        await Assert.ThrowsAsync<NotFoundAppException>(act);
    }

    [Fact]
    public async Task Given_CustomerOwnedByAnotherUser_When_Editing_Then_ThrowsNotFoundAppException()
    {
        // Given
        _repo.Setup(repository => repository.Edit(It.IsAny<Customer>())).ReturnsAsync(false);

        var dto = new CreateCustomerDto("NuevoNombre", "nuevo@test.com", "999");

        // When
        var act = () => _service.Edit(1, dto, userId: 99);

        // Then
        await Assert.ThrowsAsync<NotFoundAppException>(act);
    }
}
