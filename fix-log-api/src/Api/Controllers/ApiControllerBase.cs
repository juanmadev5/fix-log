using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace fix_log_api.Controllers
{
    [Authorize]
    public abstract class ApiControllerBase : ControllerBase
    {
        protected int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    }
}
