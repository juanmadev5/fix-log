---
tags: [backend, aspnet-core, architecture]
---

# Backend Architecture — ASP.NET Core

## Clean Architecture

Four separate `.csproj` projects, dependencies pointing inward:

```text
Api  →  Infrastructure  →  Application  →  Domain
```

- **`Domain`** — entities (`Customer`, `Expense`, `Report`, `User`), repository interfaces, domain exceptions (`NotFoundAppException`, `ConflictAppException`, `InvalidCredentialsException`, `ValidationFailedException`). No framework/package dependency — a pure class library.
- **`Application`** — use cases (`AuthService`, `CustomerService`, `ExpenseService`, `ReportService`), DTOs, FluentValidation validators, typed options (`JwtSettings`, `BcryptSettings`), the shared pagination envelope. References `Domain` only.
- **`Infrastructure`** — `AppDbContext`, EF Core Fluent API configurations, repository implementations, embedded DbUp migration scripts. References `Application` and `Domain`.
- **`Api`** — the only executable/publishable project: controllers, `Program.cs` (DI composition), middleware (`GlobalExceptionHandler`, `CorrelationIdMiddleware`). References all three layers above.

This physical separation (separate `.csproj`s, not just folders) is what makes the dependency direction impossible to break by accident — `Domain` cannot compile if something tries to make it reference EF Core or ASP.NET Core, because its `.csproj` carries no such reference.

## General principles

- **Dependency direction**: business/domain logic never depends on frameworks or infrastructure details. Infrastructure implements interfaces defined by the layer that needs them.

```csharp
// Bad — Application depends on a concrete infrastructure type
public class ReportService
{
    private readonly ReportRepository _repository; // concrete EF Core class
    public ReportService(ReportRepository repository) => _repository = repository;
}

// Good — Application depends on an abstraction it owns; Infrastructure implements it
public interface IReportRepository
{
    Task<Report?> GetByIdAsync(Guid id, Guid userId);
}

public class ReportService
{
    private readonly IReportRepository _repository;
    public ReportService(IReportRepository repository) => _repository = repository;
}
```

- **Always depend on an interface, from the first implementation** — testability alone justifies it. Applies at every layer boundary, no carve-out for "there's only one implementation today."
- **Wrap external systems behind a boundary**: nothing outside `Infrastructure` sees an external system's own field names/shapes. If a payment gateway or external API is ever added, define a model this app owns and convert at the edge.
- **Make invalid states unrepresentable** where practical: prefer a type that can't hold an invalid combination over a nullable field every consumer has to null-check.
- **Consistency within the project beats a "better" pattern mid-stream**: every feature (`Customer`, `Expense`, `Report`, `Auth`) follows the same `Domain`/`Application`/`Infrastructure`/`Api` split.

## API style — Controllers

Exposed via **Controllers** (`[ApiController]` + attribute routing) — never Minimal APIs.

- **Every endpoint must be explicitly and clearly identifiable**: every `[HttpGet]`/`[HttpPost]`/`[HttpPut]`/`[HttpDelete]` gets an explicit route template (e.g. `[HttpGet("{id}")]`), never left bare relying on the class-level route to carry the whole path.
- Reference actions via `nameof()` (`CreatedAtAction(nameof(GetById), ...)`), never a magic string.
- DTOs are explicit and separate from domain entities — never expose an EF Core entity directly through the API.
- Use `IOptions<T>`, never `IConfiguration["Some:Key"]` scattered through the codebase.

## Wire format — `snake_case`, no exceptions

**Every field on the wire — request body, response body, and query parameter — is `snake_case`, no exceptions:**

- `JsonNamingPolicy.SnakeCaseLower` is the global `PropertyNamingPolicy` via `AddControllers().AddJsonOptions(...)` in `Program.cs`. DTO properties stay PascalCase in C# — the naming policy converts them at the wire boundary.
- This only covers the MVC request/response body. It does **not** cover query-string parameter binding (`[FromQuery]` binds by the literal C# parameter name) and it is **not** automatically used by a raw `HttpResponse.WriteAsJsonAsync(...)` call outside the controller pipeline — see [error-handling.md](error-handling.md#backend-aspnet-core) for why `GlobalExceptionHandler` has to pass the same `JsonSerializerOptions` explicitly. Any new place that writes JSON outside a controller action needs the same explicit wiring.
- It also does **not** drive the generated OpenAPI schema (`/openapi/v1.json`, the Scalar UI) — per Microsoft's own docs, MVC's `JsonOptions` has "no" influence on OpenAPI schema generation; only `Microsoft.AspNetCore.Http.Json.JsonOptions` does. `Program.cs` configures that one too (`builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(...)`, same `PropertyNamingPolicy` and enum converter), specifically so the published API docs describe the same `snake_case` contract the API actually speaks instead of a stale camelCase one. Keep both configured together — there's no single config surface for all three (body, OpenAPI schema, raw `WriteAsJsonAsync`) in ASP.NET Core.
- Query params that aren't already snake_case in their C# parameter name get an explicit `[FromQuery(Name = "page_size")]` (see the three list endpoints) rather than renaming the C# parameter itself.
- Enums serialized as strings (`JsonStringEnumConverter`), never raw ints — already correct in this codebase.
- Pagination query params: `page` (1-based, default `1`), `page_size` (default `20`, max `100`).
- Pagination envelope:

```json
{
  "items": [ ... ],
  "page": 1,
  "page_size": 20,
  "total_count": 137,
  "total_pages": 7
}
```

## REST API design

- URLs represent resources (nouns), never actions — `POST /api/v1/customer`, `DELETE /api/v1/customer/{id}`.
- Plural-or-singular naming stays **consistent** across the whole API (this repo uses the singular resource segment — `customer`, `expense`, `report` — keep that consistent for any new resource).
- `GET` read-only/idempotent/cacheable; `POST` create; `PUT` full replace; `DELETE` remove. Don't use `GET`/`PUT` for anything non-idempotent.
- Status codes carry meaning: `200` read/update, `201` creation (with `Location`), `204` no-content action, `400` malformed request, `401`/`403` auth, `404` not found, `409` conflict, `422` validation, `500` unhandled.
- Query parameters — never path segments — for anything optional (filtering, sorting, pagination): `GET /api/v1/report?status=completed&page=2`, never `/api/v1/report/status/completed`.
- **Every endpoint that returns a collection is paginated, no exceptions.**
- Filters are query params named after the field they filter, applied server-side before pagination.

## API documentation — OpenAPI, no exceptions

**Every endpoint must be documented via OpenAPI.**

- **`Microsoft.AspNetCore.OpenApi`** (`AddOpenApi()` / `app.MapOpenApi()`) generates the document.
- **Scalar** (`Scalar.AspNetCore`, `app.MapScalarApiReference()`) serves the interactive UI at `/scalar/v1`.
- XML doc comments (`/// <summary>`) on every action, plus `[ProducesResponseType]` for every status the action can actually return:

```csharp
/// <summary>Creates a report for the authenticated user's customer.</summary>
[HttpPost("")]
[ProducesResponseType(typeof(ReportResponse), StatusCodes.Status201Created)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
[ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
public async Task<IActionResult> Create(CreateReportRequest request) { ... }
```

- `<GenerateDocumentationFile>true</GenerateDocumentationFile>` must be set in `Api.csproj` so XML comments flow into the generated document.
- Non-trivial DTO properties (units, format, constraints) get a doc-comment too — same restraint as [engineering-principles](engineering-principles.md#comments): not mechanically on every property.

## API versioning — URL path, no exceptions

**Every endpoint is versioned via the URL path (`/api/v1/...`).**

- **`Asp.Versioning.Mvc`** + **`Asp.Versioning.Mvc.ApiExplorer`** — already wired in `Program.cs`. `[ApiVersion("1.0")]` on the controller, `[Route("api/v{version:apiVersion}/[controller]")]`.
- `AddApiExplorer(options => options.SubstituteApiVersionInUrl = true)` is required — without it the OpenAPI doc keeps the literal `{version}` placeholder instead of the resolved segment.
- Additive changes (new optional field, new endpoint) ship on the existing version. A breaking change (removed/renamed field, changed status code/semantics) bumps the major segment (`v1` → `v2`), keeping `v1` alive until clients migrate.

## Authentication & authorization

- ASP.NET Core's own built-in middleware: `Microsoft.AspNetCore.Authentication.JwtBearer` for token validation, policy-based `[Authorize]`. No custom auth scheme.
- This app issues its own JWTs (`AuthService` + `JwtSettings`), hashed with BCrypt (`BcryptSettings`) — there is no external identity provider.
- **Per-resource authorization on every operation**: every read/write checks the resource belongs to the authenticated user — including cross-entity relations (a `Report` can only reference a `Customer` the same user owns). This is the app's core security invariant; treat any new endpoint missing this check as a blocking review finding.

## Data access

- **EF Core** as ORM/query layer only — entity configuration via **Fluent API** (`IEntityTypeConfiguration<T>` in `Infrastructure/Data/Configurations/`), never data annotations. Table/column naming follows Postgres `snake_case`, configured explicitly.
- **Schema changes never go through `dotnet ef migrations`.** **DbUp** with hand-written, versioned SQL scripts is mandatory:
  - Scripts live in `fix-log-api/src/Infrastructure/db/migration/`, named `V{number}__{description}.sql`, zero-padded, strictly sequential.
  - **A script that's already shipped is never edited** — a later schema change is a new script.
  - Embedded as assembly resources in `Infrastructure.csproj`, applied at startup gated by `RunMigrations`, wrapped in a Postgres advisory lock (already implemented in `Program.cs` with key `851201`) so concurrent replicas don't race.
  - EF Core's Fluent API configuration describes the schema the SQL scripts already created — it never generates one.

## Caching

No cache is in use yet. If one is introduced: **Redis** (`Microsoft.Extensions.Caching.StackExchangeRedis` / `IDistributedCache`), every entry with an explicit TTL, never a replacement for Postgres as the system of record.

## Validation

**FluentValidation**, one validator per request/command, decoupled from the DTO itself (`Application/Validators/`).

## Request flow

No mediator library. Controllers inject `Application` services directly via constructor injection — ASP.NET Core's own DI container, no external library.

## Rate limiting

`AddRateLimiter` with a fixed-window limiter (`"auth"`, 5 requests/minute) applied to `register`/`login` — already implemented in `Program.cs`. Apply the same pattern (a named limiter + `[EnableRateLimiting("name")]`) to any other endpoint that needs abuse protection.

## Static analysis

Mandatory before considering any backend task done:

- `dotnet build` — Roslyn analyzers, clean, no new warnings.
- `dotnet format --verify-no-changes` — style/`.editorconfig` compliance, no modification.

## Error handling, logging, and testing

See [error-handling](error-handling.md#backend-aspnet-core) and [testing](testing.md#backend-aspnet-core).
