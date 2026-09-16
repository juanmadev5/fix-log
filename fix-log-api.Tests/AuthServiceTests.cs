using fix_log_api.Application.DTOs;
using fix_log_api.Application.Options;
using fix_log_api.Application.Services;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Moq;

namespace fix_log_api.Tests;

public class AuthServiceTests
{
    private readonly Mock<IUserRepository> _repo = new();
    private readonly AuthService _service;

    public AuthServiceTests()
    {
        var jwtSettings = Options.Create(new JwtSettings
        {
            Secret = "test_secret_key_with_at_least_32_characters",
            Issuer = "test-issuer",
            Audience = "test-audience",
            ExpiryMinutes = 60
        });
        var bcryptSettings = Options.Create(new BcryptSettings { WorkFactor = 4 });

        _service = new AuthService(_repo.Object, jwtSettings, bcryptSettings, NullLogger<AuthService>.Instance);
    }

    [Fact]
    public async Task Given_NewEmail_When_Registering_Then_ReturnsToken()
    {
        // Given
        _repo.Setup(repository => repository.GetByEmail("new@test.com")).ReturnsAsync((User?)null);
        _repo.Setup(repository => repository.Create(It.IsAny<User>())).Returns(Task.CompletedTask);

        // When
        var result = await _service.Register(new RegisterDto("new@test.com", "password123"));

        // Then
        result.Token.Should().NotBeNullOrEmpty();
        result.Email.Should().Be("new@test.com");
    }

    [Fact]
    public async Task Given_ExistingEmail_When_Registering_Then_ThrowsConflictAppException()
    {
        // Given
        _repo.Setup(repository => repository.GetByEmail("existing@test.com")).ReturnsAsync(
            new User { Id = 1, Email = "existing@test.com", PasswordHash = "hash" });

        // When
        var act = () => _service.Register(new RegisterDto("existing@test.com", "password123"));

        // Then
        await act.Should().ThrowAsync<ConflictAppException>();
        _repo.Verify(repository => repository.Create(It.IsAny<User>()), Times.Never);
    }

    [Fact]
    public async Task Given_NonExistentEmail_When_LoggingIn_Then_ThrowsInvalidCredentialsException()
    {
        // Given
        _repo.Setup(repository => repository.GetByEmail("missing@test.com")).ReturnsAsync((User?)null);

        // When
        var act = () => _service.Login(new LoginDto("missing@test.com", "password"));

        // Then
        await act.Should().ThrowAsync<InvalidCredentialsException>();
    }

    [Fact]
    public async Task Given_CorrectCredentials_When_LoggingIn_Then_ReturnsToken()
    {
        // Given
        var hash = BCrypt.Net.BCrypt.HashPassword("password123", workFactor: 4);
        _repo.Setup(repository => repository.GetByEmail("user@test.com")).ReturnsAsync(
            new User { Id = 1, Email = "user@test.com", PasswordHash = hash });

        // When
        var result = await _service.Login(new LoginDto("user@test.com", "password123"));

        // Then
        result.Token.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task Given_WrongPassword_When_LoggingIn_Then_ThrowsInvalidCredentialsException()
    {
        // Given
        var hash = BCrypt.Net.BCrypt.HashPassword("password123", workFactor: 4);
        _repo.Setup(repository => repository.GetByEmail("user@test.com")).ReturnsAsync(
            new User { Id = 1, Email = "user@test.com", PasswordHash = hash });

        // When
        var act = () => _service.Login(new LoginDto("user@test.com", "wrong_password"));

        // Then
        await act.Should().ThrowAsync<InvalidCredentialsException>();
    }
}
