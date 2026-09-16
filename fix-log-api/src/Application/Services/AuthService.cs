using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Application.Options;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Exceptions;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace fix_log_api.Application.Services
{
    public class AuthService(
        IUserRepository repository,
        IOptions<JwtSettings> jwtSettings,
        IOptions<BcryptSettings> bcryptSettings,
        ILogger<AuthService> logger) : IAuthService
    {
        private readonly IUserRepository _repository = repository;
        private readonly JwtSettings _jwtSettings = jwtSettings.Value;
        private readonly BcryptSettings _bcryptSettings = bcryptSettings.Value;
        private readonly ILogger<AuthService> _logger = logger;

        public async Task<AuthResponseDto> Register(RegisterDto dto)
        {
            var existing = await _repository.GetByEmail(dto.Email);
            if (existing != null)
                throw new ConflictAppException("EMAIL_ALREADY_REGISTERED", "An account with this email already exists.");

            var user = new User
            {
                Email = dto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password, _bcryptSettings.WorkFactor)
            };

            await _repository.Create(user);
            _logger.LogInformation("User {UserId} registered", user.Id);

            var token = GenerateToken(user);

            return new AuthResponseDto(token, user.Email);
        }

        public async Task<AuthResponseDto> Login(LoginDto dto)
        {
            var user = await _repository.GetByEmail(dto.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            {
                _logger.LogWarning("Failed login attempt for {Email}", dto.Email);
                throw new InvalidCredentialsException();
            }

            var token = GenerateToken(user);
            _logger.LogInformation("User {UserId} logged in", user.Id);

            return new AuthResponseDto(token, user.Email);
        }

        private string GenerateToken(User user)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.Secret));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _jwtSettings.Issuer,
                audience: _jwtSettings.Audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(_jwtSettings.ExpiryMinutes),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
