using Asp.Versioning;
using Asp.Versioning.ApiExplorer;
using DbUp;
using fix_log_api.Api.Middleware;
using fix_log_api.Application.Interfaces;
using fix_log_api.Application.Options;
using fix_log_api.Application.Services;
using fix_log_api.Application.Validators;
using fix_log_api.Domain.Interfaces;
using fix_log_api.Infrastructure.Data;
using fix_log_api.Infrastructure.Data.Repositories;
using FluentValidation;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Npgsql;
using Scalar.AspNetCore;
using Serilog;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, configuration) =>
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .WriteTo.Console());

builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

// MVC's JsonOptions above only governs controller request/response bodies - it has no effect on
// the generated OpenAPI schema. The schema is driven by this separate options object instead
// (also what a bare HttpResponse.WriteAsJsonAsync falls back to), so it needs the same policy
// or the Scalar/OpenAPI docs describe a camelCase contract while the API actually speaks snake_case.
builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

var defaultApiVersion = new ApiVersion(1);

builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = defaultApiVersion;
    options.ReportApiVersions = true;
    options.ApiVersionReader = new UrlSegmentApiVersionReader();
})
    .AddMvc()
    .AddApiExplorer(options =>
    {
        options.SubstituteApiVersionInUrl = true;
        options.GroupNameFormat = "'v'VVV";
    })
    .AddOpenApi();

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddFixedWindowLimiter("auth", limiterOptions =>
    {
        limiterOptions.PermitLimit = 5;
        limiterOptions.Window = TimeSpan.FromMinutes(1);
        limiterOptions.QueueLimit = 0;
    });
});

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        var allowedOrigins = builder.Configuration
            .GetSection("CorsSettings:AllowedOrigins")
            .Get<string[]>() ?? [];

        policy.WithOrigins(allowedOrigins)
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();
builder.Services.AddScoped<IExpenseRepository, ExpenseRepository>();
builder.Services.AddScoped<IReportRepository, ReportRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<IExpenseService, ExpenseService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IAuthService, AuthService>();

builder.Services.AddValidatorsFromAssemblyContaining<RegisterDtoValidator>();

builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection(JwtSettings.SectionName));
builder.Services.Configure<BcryptSettings>(builder.Configuration.GetSection(BcryptSettings.SectionName));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();
builder.Services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
    .Configure<IOptions<JwtSettings>>((bearerOptions, jwtSettingsOptions) =>
    {
        var jwtSettings = jwtSettingsOptions.Value;

        bearerOptions.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidAudience = jwtSettings.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.Secret))
        };
    });

var app = builder.Build();

if (app.Configuration.GetValue<bool>("RunMigrations"))
{
    const long advisoryLockKey = 851201;

    using var lockConnection = new NpgsqlConnection(connectionString);
    lockConnection.Open();

    using (var lockCommand = new NpgsqlCommand($"SELECT pg_advisory_lock({advisoryLockKey})", lockConnection))
    {
        lockCommand.ExecuteNonQuery();
    }

    try
    {
        Log.Information("Applying pending database migrations");

        var upgrader = DeployChanges.To
            .PostgresqlDatabase(connectionString)
            .WithScriptsEmbeddedInAssembly(typeof(AppDbContext).Assembly)
            .WithTransactionPerScript()
            .LogToConsole()
            .Build();

        var result = upgrader.PerformUpgrade();

        if (!result.Successful)
        {
            Log.Error(result.Error, "Database migration failed");
            throw new InvalidOperationException("DbUp migration failed", result.Error);
        }

        Log.Information("Database migrations applied successfully");
    }
    finally
    {
        using var unlockCommand = new NpgsqlCommand($"SELECT pg_advisory_unlock({advisoryLockKey})", lockConnection);
        unlockCommand.ExecuteNonQuery();
    }
}

app.UseMiddleware<CorrelationIdMiddleware>();
app.UseExceptionHandler();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi().WithDocumentPerVersion();

    var apiVersionDescriptions = app.Services.GetRequiredService<IApiVersionDescriptionProvider>().ApiVersionDescriptions;
    app.MapScalarApiReference(options =>
    {
        foreach (var description in apiVersionDescriptions)
        {
            options.AddDocument(
                description.GroupName,
                $"v{description.ApiVersion.MajorVersion}",
                routePattern: $"/openapi/{description.GroupName}.json");
        }
    });
}

app.UseHttpsRedirection();

app.UseCors();

app.UseRateLimiter();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
