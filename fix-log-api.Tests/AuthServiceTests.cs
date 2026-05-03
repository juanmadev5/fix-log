using fix_log_api.Application.DTOs;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Moq;

namespace fix_log_api.Tests;

public class AuthServiceTests
{
    private readonly Mock<IUserRepository> _repo = new();
    private readonly AuthService _service;

    public AuthServiceTests()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["JwtSettings:Secret"] = "clave_de_prueba_que_tiene_al_menos_32_caracteres",
                ["JwtSettings:Issuer"] = "test-issuer",
                ["JwtSettings:Audience"] = "test-audience",
                ["JwtSettings:ExpiryMinutes"] = "60",
                ["BcryptSettings:WorkFactor"] = "4"
            })
            .Build();

        _service = new AuthService(_repo.Object, config);
    }

    [Fact]
    public async Task Register_WithNewEmail_ReturnsSuccess()
    {
        _repo.Setup(r => r.GetByEmail("nuevo@test.com")).ReturnsAsync((User?)null);
        _repo.Setup(r => r.Create(It.IsAny<User>())).ReturnsAsync(true);

        var result = await _service.Register(new RegisterDto("nuevo@test.com", "password123"));

        Assert.Equal(Status.SUCCESS, result.Status);
        Assert.NotNull(result.Response?.Token);
    }

    [Fact]
    public async Task Register_WithExistingEmail_ReturnsFailed()
    {
        _repo.Setup(r => r.GetByEmail("existente@test.com")).ReturnsAsync(
            new User { Id = 1, Email = "existente@test.com", PasswordHash = "hash" }
        );

        var result = await _service.Register(new RegisterDto("existente@test.com", "password123"));

        Assert.Equal(Status.FAILED, result.Status);
        _repo.Verify(r => r.Create(It.IsAny<User>()), Times.Never);
    }

    [Fact]
    public async Task Login_WithNonExistentEmail_ReturnsFailed()
    {
        _repo.Setup(r => r.GetByEmail("noexiste@test.com")).ReturnsAsync((User?)null);

        var result = await _service.Login(new LoginDto("noexiste@test.com", "password"));

        Assert.Equal(Status.FAILED, result.Status);
    }

    [Fact]
    public async Task Login_WithCorrectCredentials_ReturnsSuccess()
    {
        var hash = BCrypt.Net.BCrypt.HashPassword("password123", workFactor: 4);
        _repo.Setup(r => r.GetByEmail("usuario@test.com")).ReturnsAsync(
            new User { Id = 1, Email = "usuario@test.com", PasswordHash = hash }
        );

        var result = await _service.Login(new LoginDto("usuario@test.com", "password123"));

        Assert.Equal(Status.SUCCESS, result.Status);
        Assert.NotNull(result.Response?.Token);
    }

    [Fact]
    public async Task Login_WithWrongPassword_ReturnsFailed()
    {
        var hash = BCrypt.Net.BCrypt.HashPassword("password123", workFactor: 4);
        _repo.Setup(r => r.GetByEmail("usuario@test.com")).ReturnsAsync(
            new User { Id = 1, Email = "usuario@test.com", PasswordHash = hash }
        );

        var result = await _service.Login(new LoginDto("usuario@test.com", "contraseña_incorrecta"));

        Assert.Equal(Status.FAILED, result.Status);
    }
}
