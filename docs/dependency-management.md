---
tags: [global, dependencies]
---

# Dependency Management

Applies to both `fix-log-api` (NuGet) and `fix_log` (pub) — how a dependency is chosen, versioned, and kept up to date.

## Before adding a new dependency

- **Check an existing dependency doesn't already solve it.** Adding a second package for something already covered by one already installed is duplication at the dependency level, not just the code level.
- **Maintenance is active** — recent commits/releases, issues actually getting responses, not a package that's gone quiet for a year or more.
- **No commercial or paid licenses, ever.** Never add a package that requires a commercial license or a per-seat/per-usage fee — including one that was free in an earlier version and went paid in a later one. Check the license of the *exact version* being added, not just the package's reputation. If the only good option is commercial, find an alternative or write the code; don't ask for an exception.
  - `FluentAssertions` is the concrete trap to watch for in this repo: versions **8 and later require a commercial license**. The backend test project (`fix-log-api.Tests`) does not use it — see [backend-testing](testing.md#backend-aspnet-core) for why xUnit's own `Assert` is the default here instead.
- If a dependency fails any of these, it's a question for the developer, not a judgment call to make silently.

## Versioning

- **Caret/tilde ranges are allowed for minor/patch versions** (`^1.2.3` in `pubspec.yaml`, `Version="X.Y.*"`-style floating in a `.csproj` if ever used) — never a range that allows a major version bump, since that's where breaking changes live.
- The lockfile is what actually pins the resolved version — `fix-log-api/**/obj/project.assets.json`'s source of truth is `packages.lock.json` if lock files are enabled, and `pubspec.lock` for Flutter — always committed for the Flutter app (`pubspec.lock` is tracked; NuGet restore is deterministic per `.csproj` pin).
- Bumping a major version is a deliberate, reviewed change (read the changelog, check for breaking changes called out) — never an incidental side effect of a routine `dotnet restore`/`flutter pub upgrade`.

## Keeping dependencies current

- Backend: `dotnet list package --vulnerable` / `dotnet list package --outdated`, run manually.
- Frontend: `flutter pub outdated`, run manually.
- No centralized bot/service (Snyk, Dependabot, Renovate) wired up at this point — a deliberate choice, revisit if the project's context calls for it.
