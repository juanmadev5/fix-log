using fix_log_api.Application.DTOs;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;

namespace fix_log_api.Tests;

public class ReportServiceTests
{
    private readonly Mock<IReportRepository> _repo = new();
    private readonly Mock<ICustomerRepository> _customerRepo = new();
    private readonly ReportService _service;

    public ReportServiceTests()
    {
        _service = new ReportService(_repo.Object, _customerRepo.Object, NullLogger<ReportService>.Instance);
    }

    private void GivenCustomerOwnedByUser(int customerId, int userId)
    {
        _customerRepo.Setup(repository => repository.GetById(customerId, userId)).ReturnsAsync(
            new Customer { Id = customerId, UserId = userId, Name = "Juan", Email = "juan@test.com", PhoneNumber = "123", Reports = [] });
    }

    [Fact]
    public async Task Given_ValidData_When_Creating_Then_ReturnsCreatedReport()
    {
        // Given
        GivenCustomerOwnedByUser(customerId: 1, userId: 1);
        _repo.Setup(repository => repository.Create(It.IsAny<Report>())).Returns(Task.CompletedTask);

        var dto = new CreateReportDto(1, DateTime.UtcNow, "Reparacion de pantalla", false, false, 150000m);

        // When
        var result = await _service.Create(dto, userId: 1);

        // Then
        result.Should().NotBeNull();
    }

    [Fact]
    public async Task Given_CustomerOwnedByAnotherUser_When_Creating_Then_ThrowsNotFoundAppException()
    {
        // Given
        _customerRepo.Setup(repository => repository.GetById(1, 99)).ReturnsAsync((Customer?)null);

        var dto = new CreateReportDto(1, DateTime.UtcNow, "Reparacion de pantalla", false, false, 150000m);

        // When
        var act = () => _service.Create(dto, userId: 99);

        // Then
        await act.Should().ThrowAsync<NotFoundAppException>();
        _repo.Verify(repository => repository.Create(It.IsAny<Report>()), Times.Never);
    }

    [Fact]
    public async Task Given_CustomerOwnedByAnotherUser_When_Editing_Then_ThrowsNotFoundAppException()
    {
        // Given
        _customerRepo.Setup(repository => repository.GetById(1, 99)).ReturnsAsync((Customer?)null);

        var dto = new CreateReportDto(1, DateTime.UtcNow, "Reparacion de pantalla", false, false, 150000m);

        // When
        var act = () => _service.Edit(1, dto, userId: 99);

        // Then
        await act.Should().ThrowAsync<NotFoundAppException>();
        _repo.Verify(repository => repository.Edit(It.IsAny<Report>()), Times.Never);
    }

    [Fact]
    public async Task Given_OwnedReport_When_Deleting_Then_Succeeds()
    {
        // Given
        _repo.Setup(repository => repository.Delete(1, 1)).ReturnsAsync(true);

        // When
        var act = () => _service.Delete(1, userId: 1);

        // Then
        await act.Should().NotThrowAsync();
    }

    [Fact]
    public async Task Given_ReportOwnedByAnotherUser_When_Deleting_Then_ThrowsNotFoundAppException()
    {
        // Given
        _repo.Setup(repository => repository.Delete(1, 99)).ReturnsAsync(false);

        // When
        var act = () => _service.Delete(1, userId: 99);

        // Then
        await act.Should().ThrowAsync<NotFoundAppException>();
    }

    [Fact]
    public async Task Given_ExistingReports_When_GettingAll_Then_ReturnsThem()
    {
        // Given
        _repo.Setup(repository => repository.GetAll(1, It.IsAny<int>(), It.IsAny<int>())).ReturnsAsync(
        ([
            new() { Id = 1, UserId = 1, CustomerId = 1, Date = DateTime.UtcNow, Details = "Test", IsCompleted = true, IsPaid = true, Cost = 100m }
        ], 1));

        // When
        var result = await _service.GetAll(1, 1, 20);

        // Then
        result.Items.Should().ContainSingle();
    }
}
