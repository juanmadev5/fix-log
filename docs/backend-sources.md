---
tags: [backend, documentation, sources]
---

# Sources — ASP.NET Core

Curated index of this stack's official documentation — consult these first. Only the vendor/maintainer's own docs (or the relevant RFC) count as a source — see [Sources Policy](#sources-policy) below.

## Official domains

`learn.microsoft.com` (ASP.NET Core, EF Core, and any other Microsoft-owned library) plus each library's own docs domain below.

## ASP.NET Core

- Controllers / `[ApiController]` overview: <https://learn.microsoft.com/aspnet/core/web-api/>
- Dependency injection overview: <https://learn.microsoft.com/aspnet/core/fundamentals/dependency-injection>

## Authentication & authorization

- JWT Bearer authentication overview: <https://learn.microsoft.com/aspnet/core/security/authentication/jwt-authn>
- Policy-based authorization: <https://learn.microsoft.com/aspnet/core/security/authorization/policies>

## EF Core

- Fluent API model configuration: <https://learn.microsoft.com/ef/core/modeling/>
- `IEntityTypeConfiguration<TEntity>` reference: <https://learn.microsoft.com/dotnet/api/microsoft.entityframeworkcore.ientitytypeconfiguration-1>

## Microsoft.AspNetCore.OpenApi

- Overview: <https://learn.microsoft.com/aspnet/core/fundamentals/openapi/overview>
- Generate OpenAPI documents: <https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi>

## Scalar

- ASP.NET Core integration: <https://guides.scalar.com/scalar/scalar-api-references/net-integration>

## Asp.Versioning

- Getting started: <https://dotnet.github.io/aspnet-api-versioning/getting-started.html>
- URL path/segment versioning for MVC controllers: <https://dotnet.github.io/aspnet-api-versioning/aspnet-core/how-to/version-by-url.html>

## FluentValidation

- Official documentation home: <https://docs.fluentvalidation.net/en/latest/>
- Creating your first validator: <https://docs.fluentvalidation.net/en/latest/start.html>

## xUnit

- Official documentation home: <https://xunit.net/>
- Getting Started (v3, .NET SDK command line): <https://xunit.net/docs/getting-started/v3/getting-started>

## Moq

- Official repository (devlooped/moq, the actively maintained fork): <https://github.com/devlooped/moq>
- Quickstart wiki: <https://github.com/devlooped/moq/wiki/Quickstart>

## Testcontainers for .NET

- Official documentation home: <https://dotnet.testcontainers.org/>
- PostgreSQL module: <https://dotnet.testcontainers.org/modules/postgres/>

## DbUp

- Official documentation home: <https://dbup.readthedocs.io/en/latest/>
- Script providers (`WithScriptsEmbeddedInAssembly`): <https://dbup.readthedocs.io/en/latest/more-info/script-providers/>

## Serilog

- Official site and documentation home: <https://serilog.net/>

## RFC 7807

- Problem Details for HTTP APIs — note: obsoleted by RFC 9457, worth checking if the newer RFC should be adopted instead: <https://www.rfc-editor.org/rfc/rfc7807>

## Sources Policy

- Only the source's own official documentation — never blogs, Medium/dev.to, Stack Overflow, random tutorials, or AI-generated summaries, even if one turns up first in a search.
- If a task needs an official doc source not listed above: look it up directly (same official-only rule), then add it here under a new `##` heading, or to `docs/SOURCES.md` if it's a one-off not worth promoting to this curated list.
