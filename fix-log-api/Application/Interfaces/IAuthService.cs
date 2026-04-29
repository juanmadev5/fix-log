using fix_log_api.Application.DTOs;
using fix_log_api.Domain.Common;

namespace fix_log_api.Application.Interfaces
{
    public interface IAuthService
    {
        Task<ActionResponse<AuthResponseDto>> Register(RegisterDto dto);
        Task<ActionResponse<AuthResponseDto>> Login(LoginDto dto);
    }
}
