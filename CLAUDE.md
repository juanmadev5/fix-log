# fix-log — Agent Guide

This file is the entry point for any agent working in this repository. It doesn't restate the architecture already covered in the root [README.md](README.md) — read that first for the stack, the folder layout, and the API endpoint table. This file points at the project's own conventions in [`docs/`](docs/), self-contained — no live dependency on any external conventions repository.

## Repository shape

Two independent projects in one repo:

- **`fix-log-api/`** — backend, ASP.NET Core 10, Clean Architecture.
- **`fix_log/`** — frontend, Flutter (Windows, Linux, Android, iOS), UI/Domain/Data (MVVM).

## Reading order

1. **[docs/engineering-principles.md](docs/engineering-principles.md)** — naming, DRY/SOLID, comments, magic values, definition of done, scope discipline, ask-vs-assume. Applies to both projects.
2. **[docs/git-conventions.md](docs/git-conventions.md)**, **[docs/dependency-management.md](docs/dependency-management.md)**, **[docs/testing.md](docs/testing.md)**, **[docs/error-handling.md](docs/error-handling.md)**, **[docs/code-review.md](docs/code-review.md)** — cross-cutting rules, each with a backend and a frontend section where the mechanism differs.
3. Whichever side the task touches:
   - Backend: **[docs/backend-architecture.md](docs/backend-architecture.md)**, **[docs/backend-coding-standards.md](docs/backend-coding-standards.md)**, **[docs/backend-sources.md](docs/backend-sources.md)**.
   - Frontend: **[docs/frontend-architecture.md](docs/frontend-architecture.md)**, **[docs/frontend-coding-standards.md](docs/frontend-coding-standards.md)**, **[docs/frontend-sources.md](docs/frontend-sources.md)**.

## Decisions already made — don't re-ask

- **No i18n.** The Flutter app is Spanish-UI-only, deliberately, with no `flutter_localizations`/ARB layer. See [docs/frontend-architecture.md](docs/frontend-architecture.md#internationalization-i18n).
- **No mediator library, no Minimal APIs, no EF Core Migrations** — Controllers + DbUp, per [docs/backend-architecture.md](docs/backend-architecture.md).
- **No crash-reporting service** wired up yet (deliberate current scope) — see [docs/error-handling.md](docs/error-handling.md#crash-reporting).
- **No cache layer yet.** If one is introduced, it's Redis per [docs/backend-architecture.md](docs/backend-architecture.md#caching) — never a substitute for Postgres as the system of record.

## Compliance history

`docs/` was written against the actual code, then three gaps it exposed were closed in the same pass — don't rediscover these as "new" findings:

1. **Wire format is now `snake_case` end to end**, per [docs/backend-architecture.md](docs/backend-architecture.md#wire-format--snake_case-no-exceptions): `JsonNamingPolicy.SnakeCaseLower` on `AddControllers().AddJsonOptions(...)` in `Program.cs`, `[FromQuery(Name = "page_size")]` on the three list endpoints, and the `fix_log` client's models/services/queries updated to match. Verified live against a running instance (Postgres in Docker), request bodies, response bodies, the pagination envelope, and query params all consistently `snake_case`.
2. **`dev` branch created** locally off `main`, per [docs/git-conventions.md](docs/git-conventions.md#branching).
3. **`FluentAssertions` removed** from `fix-log-api.Tests` — rewritten to xUnit's own `Assert`, per [docs/testing.md](docs/testing.md#backend-aspnet-core).
4. **Three separate "which `JsonOptions` actually applies here" traps, all found by testing error/docs paths live, not by reading code**: ASP.NET Core has no single config surface for JSON naming — `Microsoft.AspNetCore.Mvc.JsonOptions` (`AddControllers().AddJsonOptions`) only governs controller-action bodies.
   - `GlobalExceptionHandler`'s bare `WriteAsJsonAsync(problemDetails, cancellationToken)` ignored it and fell back to ASP.NET Core's own defaults — fixed by explicitly passing `jsonOptions.Value.JsonSerializerOptions` (`IOptions<JsonOptions>` injected). See [docs/error-handling.md](docs/error-handling.md#backend-aspnet-core).
   - The generated OpenAPI schema (`/openapi/v1.json`, Scalar UI) ignored it too — per Microsoft's own docs, MVC `JsonOptions` has no influence on OpenAPI schema generation, only `Microsoft.AspNetCore.Http.Json.JsonOptions` does. Fixed by also configuring that one with the same policy in `Program.cs`. See [docs/backend-architecture.md](docs/backend-architecture.md#wire-format--snake_case-no-exceptions).
   - **`CorrelationIdMiddleware` lost its `X-Correlation-Id` header on every error response** (404/409/422/401/500 — any response an `IExceptionHandler` writes): it set the header directly on `context.Response.Headers` before calling `next()`, but the exception-handling middleware resets the response before `GlobalExceptionHandler` writes the error body, wiping that header. Fixed by registering the header assignment via `context.Response.OnStarting(...)` instead, which runs right before headers are actually sent, after that reset. Verified live: 5/5 repeated error requests now carry the header, including a client-supplied id being echoed back. **If `X-Correlation-Id` ever goes missing again on some new response path, this is the first thing to check** — don't assume setting a response header early in a middleware is safe once anything downstream can throw.
5. **Validation-error `field` values were PascalCase (`PhoneNumber`), not `snake_case` (`phone_number`)** — every controller built `FieldError` straight from FluentValidation's `ValidationFailure.PropertyName`, 8 duplicated call sites across 4 controllers. Fixed by extracting `validation.ThrowIfInvalid()` (`Api/Controllers/ValidationResultExtensions.cs`), which runs the property name through `JsonNamingPolicy.SnakeCaseLower.ConvertName(...)` first — this also deduplicated the 8 near-identical blocks into one. Nothing in the Flutter client currently reads `fieldErrors`/`.field` to highlight a specific form widget, so this had no visible symptom yet, but it would have broken silently the moment per-field inline validation was added.
6. **The `fix_log` Flutter client's wire-format migration was verified live, not just by reading the migrated code**: a temporary `flutter_test` file drove the real `ApiClient` + `*RemoteDataSourceHttp` classes against the running backend — register/login, create a customer (`phone_number` in the request body), create a report (`customer_id`/`is_completed`/`is_paid`), re-fetch and parse the nested `reports` array inside a customer, and trigger a real 422 to confirm `AppException.fieldErrors` comes back as `phone_number` (proving fix 5 above end to end from the client's perspective too). All passed; the test file was deleted afterward — it needs a live backend, so it was never meant to join the permanent suite.
