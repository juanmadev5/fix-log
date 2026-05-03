using fix_log_api.Application.DTOs;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Moq;

namespace fix_log_api.Tests;

public class ReportServiceTests
{
    private readonly Mock<IReportRepository> _repo = new();
    private readonly ReportService _service;

    public ReportServiceTests()
    {
        _service = new ReportService(_repo.Object);
    }

    [Fact]
    public async Task Create_WithValidData_ReturnsSuccess()
    {
        _repo.Setup(r => r.Create(It.IsAny<Report>())).ReturnsAsync(true);

        var dto = new CreateReportDto(1, DateTime.UtcNow, "Reparación de pantalla", false, false, 150000m);
        var result = await _service.Create(dto, userId: 1);

        Assert.Equal(Status.SUCCESS, result.Status);
        Assert.NotNull(result.Response);
    }

    [Fact]
    public async Task Delete_WithCorrectUser_ReturnsSuccess()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Report { Id = 1, UserId = 1, CustomerId = 1, Date = DateTime.UtcNow, Details = "Test", IsCompleted = false, IsPaid = false, Cost = 0 }
        );
        _repo.Setup(r => r.Delete(1)).ReturnsAsync(true);

        var result = await _service.Delete(1, userId: 1);

        Assert.Equal(Status.SUCCESS, result.Status);
    }

    [Fact]
    public async Task Delete_WithWrongUser_ReturnsNotFound_AndNeverCallsRepo()
    {
        _repo.Setup(r => r.GetById(1)).ReturnsAsync(
            new Report { Id = 1, UserId = 1, CustomerId = 1, Date = DateTime.UtcNow, Details = "Test", IsCompleted = false, IsPaid = false, Cost = 0 }
        );

        var result = await _service.Delete(1, userId: 99);

        Assert.Equal(Status.NOT_FOUND, result.Status);
        _repo.Verify(r => r.Delete(It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task GetAll_WithExistingReports_ReturnsSuccess()
    {
        _repo.Setup(r => r.GetAll(1)).ReturnsAsync(
        [
            new() { Id = 1, UserId = 1, CustomerId = 1, Date = DateTime.UtcNow, Details = "Test", IsCompleted = true, IsPaid = true, Cost = 100m }
        ]);

        var result = await _service.GetAll(1);

        Assert.Equal(Status.SUCCESS, result.Status);
        Assert.Single(result.Response!);
    }
}
