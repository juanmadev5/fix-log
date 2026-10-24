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

1. **Wire format is now `snake_case` end to end**, per [docs/backend-architecture.md](docs/backend-architecture.md#wire-format--snake_case-no-exceptions): `JsonNamingPolicy.SnakeCaseLower` on `AddControllers().AddJsonOptions(...)` in `Program.cs`, `[FromQuery(Name = "page_size")]` on the three list endpoints, and the `fix_log` client's models/services/queries updated to match. **Also fixed in the same pass**: `GlobalExceptionHandler` was writing error responses with a bare `WriteAsJsonAsync(problemDetails, cancellationToken)`, which silently falls back to ASP.NET Core's camelCase "web defaults" instead of the `JsonOptions` configured above — those are two independent config objects in ASP.NET Core, not one. It now explicitly passes `jsonOptions.Value.JsonSerializerOptions` (see [docs/error-handling.md](docs/error-handling.md#backend-aspnet-core)). Treat any other direct `WriteAsJsonAsync`/raw-JSON-write call the same way.
2. **`dev` branch created** locally off `main`, per [docs/git-conventions.md](docs/git-conventions.md#branching).
3. **`FluentAssertions` removed** from `fix-log-api.Tests` — rewritten to xUnit's own `Assert`, per [docs/testing.md](docs/testing.md#backend-aspnet-core).
