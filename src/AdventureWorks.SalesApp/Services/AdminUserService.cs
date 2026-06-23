using AdventureWorks.SalesApp.Data;
using Microsoft.AspNetCore.Identity;

namespace AdventureWorks.SalesApp.Services;

public class UsuarioAdminDto
{
    public string Id { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? UserName { get; set; }
    public bool EmailConfirmed { get; set; }
    public IList<string> Roles { get; set; } = [];
}

public class CrearUsuarioRequest
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Rol { get; set; } = "Usuario";
}

public interface IAdminUserService
{
    Task<IEnumerable<UsuarioAdminDto>> ListarUsuariosAsync();
    Task<IdentityResult> CrearUsuarioAsync(CrearUsuarioRequest request);
    Task<IdentityResult> ActualizarRolesAsync(string userId, IEnumerable<string> roles);
    Task<IdentityResult> ReiniciarPasswordAsync(string userId, string nuevaPassword);
    Task<IdentityResult> EliminarUsuarioAsync(string userId);
}

public class AdminUserService : IAdminUserService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;

    private static readonly string[] RolesDisponibles = ["Administrador", "Usuario", "Reportes", "Ventas"];

    public AdminUserService(UserManager<ApplicationUser> userManager, RoleManager<IdentityRole> roleManager)
    {
        _userManager = userManager;
        _roleManager = roleManager;
    }

    public async Task<IEnumerable<UsuarioAdminDto>> ListarUsuariosAsync()
    {
        await EnsureRolesAsync();
        var users = _userManager.Users.ToList();
        var result = new List<UsuarioAdminDto>();
        foreach (var u in users)
        {
            result.Add(new UsuarioAdminDto
            {
                Id = u.Id,
                Email = u.Email,
                UserName = u.UserName,
                EmailConfirmed = u.EmailConfirmed,
                Roles = await _userManager.GetRolesAsync(u)
            });
        }
        return result;
    }

    public async Task<IdentityResult> CrearUsuarioAsync(CrearUsuarioRequest request)
    {
        await EnsureRolesAsync();
        var user = new ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            EmailConfirmed = true
        };
        var result = await _userManager.CreateAsync(user, request.Password);
        if (result.Succeeded)
            await _userManager.AddToRoleAsync(user, request.Rol);
        return result;
    }

    public async Task<IdentityResult> ActualizarRolesAsync(string userId, IEnumerable<string> roles)
    {
        await EnsureRolesAsync();
        var user = await _userManager.FindByIdAsync(userId);
        if (user is null) return IdentityResult.Failed(new IdentityError { Description = "Usuario no encontrado." });

        var actuales = await _userManager.GetRolesAsync(user);
        await _userManager.RemoveFromRolesAsync(user, actuales);
        return await _userManager.AddToRolesAsync(user, roles.Where(r => RolesDisponibles.Contains(r)));
    }

    public async Task<IdentityResult> ReiniciarPasswordAsync(string userId, string nuevaPassword)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user is null) return IdentityResult.Failed(new IdentityError { Description = "Usuario no encontrado." });

        var token = await _userManager.GeneratePasswordResetTokenAsync(user);
        return await _userManager.ResetPasswordAsync(user, token, nuevaPassword);
    }

    public async Task<IdentityResult> EliminarUsuarioAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user is null) return IdentityResult.Failed(new IdentityError { Description = "Usuario no encontrado." });
        return await _userManager.DeleteAsync(user);
    }

    private async Task EnsureRolesAsync()
    {
        foreach (var rol in RolesDisponibles)
        {
            if (!await _roleManager.RoleExistsAsync(rol))
                await _roleManager.CreateAsync(new IdentityRole(rol));
        }
    }
}
