using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace fix_log_api.Application.Services
{
    public class AuthService(IUserRepository repository, IConfiguration configuration) : IAuthService
    {
        private readonly IUserRepository _repository = repository;
        private readonly IConfiguration _configuration = configuration;

        public async Task<ActionResponse<AuthResponseDto>> Register(RegisterDto dto)
        {
            var existing = await _repository.GetByEmail(dto.Email);

            if (existing != null)
            {
                return new ActionResponse<AuthResponseDto>(
                    null,
                    "Ya existe una cuenta con ese correo electrónico.",
                    Status.FAILED
                );
            }

            int workFactor = _configuration.GetValue<int>("BcryptSettings:WorkFactor", 12);

            var user = new User
            {
                Email = dto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password, workFactor)
            };

            bool success = await _repository.Create(user);

            if (!success)
            {
                return new ActionResponse<AuthResponseDto>(
                    null,
                    "No se pudo registrar el usuario.",
                    Status.FAILED
                );
            }

            var token = GenerateToken(user);

            return new ActionResponse<AuthResponseDto>(
                new AuthResponseDto(token, user.Email),
                "Usuario registrado con éxito.",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<AuthResponseDto>> Login(LoginDto dto)
        {
            var user = await _repository.GetByEmail(dto.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            {
                return new ActionResponse<AuthResponseDto>(
                    null,
                    "Credenciales inválidas.",
                    Status.FAILED
                );
            }

            var token = GenerateToken(user);

            return new ActionResponse<AuthResponseDto>(
                new AuthResponseDto(token, user.Email),
                "Inicio de sesión exitoso.",
                Status.SUCCESS
            );
        }

        private string GenerateToken(User user)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secret = jwtSettings["Secret"]!;
            var issuer = jwtSettings["Issuer"]!;
            var audience = jwtSettings["Audience"]!;
            var expiryMinutes = jwtSettings.GetValue<int>("ExpiryMinutes", 60);

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
