---
tags: [error-handling, logging]
---

# Error Handling & Logging

## Exception handling

- Failures are caught and mapped in **one central place** per side — never try/catch scattered per endpoint or widget/Cubit.
- Domain/application errors are specific types, never a generic exception caught and stringly-typed.
- Any error surfaced to a caller carries a stable, predictable code (`CUSTOMER_NOT_FOUND`, never a raw exception message) plus a human-readable message with relevant context — never a generic "something went wrong".
- Never surface a raw exception message or stack trace in end-user-facing UI.
- Never include sensitive data (passwords, tokens, secrets) in an error message, log entry, or exception payload — not even at debug level.

## Logging

- Leveled, structured logging always — never bare `Console.WriteLine`/`print`/`debugPrint` scattered through the code.
- Levels: `error` for failures needing attention, `warn` for recoverable/unexpected situations, `info` for business-relevant events (report created, user logged in), `debug` for development-only detail.
- Structured logging: named fields / message templates, never string-interpolated messages.
- `debug`/`info` output is stripped or no-op'd in the Flutter release build and never shipped to a real device.

## Correlation ID

The `X-Correlation-Id` header traces one failure end-to-end, Flutter client to API.

- **Backend**: `CorrelationIdMiddleware` (`fix-log-api/src/Api/Middleware/CorrelationIdMiddleware.cs`) generates one early in the pipeline when the client doesn't send it, includes it in the response, and pushes it onto the Serilog log context for the lifetime of the request.
- **Client**: every outgoing `ApiClient` request attaches the current `X-Correlation-Id` if one is already known for the ongoing flow (e.g. carried from a previous response in a multi-step operation); otherwise it's left for the backend to generate. The response's `X-Correlation-Id` is read into any client-side log line related to that request.

## Crash reporting

No crash-reporting service (Sentry, Firebase Crashlytics) is wired up — the Flutter global error boundary logs locally and shows fallback UI. Deliberate current scope, not an oversight.

## Backend (ASP.NET Core)

- **Mandatory**: a single `IExceptionHandler` implementation (`GlobalExceptionHandler`, registered via `AddExceptionHandler<T>()` + `app.UseExceptionHandler()`) maps every domain exception to an HTTP response. Never try/catch scattered per controller action.
- Responses follow **RFC 7807 `ProblemDetails`** (`AddProblemDetails()`) with a stable `code` field added, e.g.:

```json
{
  "status": 404,
  "title": "CUSTOMER_NOT_FOUND",
  "detail": "Customer 42 was not found.",
  "code": "CUSTOMER_NOT_FOUND"
}
```

  Validation errors (422) add an `errors` array of `{ field, message }` — `field` is the `snake_case` wire name (`phone_number`), never FluentValidation's raw `PropertyName` (`PhoneNumber`). Every controller gets this via `validation.ThrowIfInvalid()` (`Api/Controllers/ValidationResultExtensions.cs`), which runs `error.PropertyName` through `JsonNamingPolicy.SnakeCaseLower.ConvertName(...)` before building each `FieldError` — call that extension instead of constructing `ValidationFailedException`/`FieldError` by hand, or the casing bug comes back.
- **`GlobalExceptionHandler` writes this response with `httpContext.Response.WriteAsJsonAsync(problemDetails, jsonOptions.Value.JsonSerializerOptions, ...)`, explicitly passing the same `Microsoft.AspNetCore.Mvc.JsonOptions` controllers use (injected via `IOptions<JsonOptions>`).** This is defense-in-depth, not optional boilerplate: `WriteAsJsonAsync` without an explicit `JsonSerializerOptions` falls back to `Microsoft.AspNetCore.Http.Json.JsonOptions` — a *different* options object than MVC's, and one that `Program.cs` happens to also configure with the same `snake_case` policy (for the OpenAPI schema's sake, see [backend-architecture.md](backend-architecture.md#wire-format--snake_case-no-exceptions)) — but relying on that silently would mean one change to either options block can quietly desync the other. Pass the options explicitly at every such call site instead of trusting the fallback to stay correct.
- Domain exceptions live in `Domain/Exceptions/` — `NotFoundAppException`, `ConflictAppException`, `InvalidCredentialsException`, `ValidationFailedException` — one exception type per category, mapped to its HTTP status + code inside `GlobalExceptionHandler`, never a new per-endpoint try/catch.
- **Serilog** for structured logging, written with message templates (`Log.Information("Customer {CustomerId} created for {UserId}", customerId, userId)`), never string interpolation.
- Correlation ID attached via `LogContext.PushProperty("CorrelationId", id)` for the lifetime of the request.

## Frontend (Flutter)

- The **data layer** (`data/services/`, `data/repositories/`) is where raw `http` package exceptions (`SocketException`, non-2xx responses) get caught and mapped into a typed `AppException` (`domain/exceptions/`) — a Cubit never catches a raw HTTP/socket exception directly.
- A Cubit that calls a repository and gets an `AppException` maps it into an error state (a sealed state class carrying the failure) — the View reads that state and renders the corresponding UI; it never catches exceptions itself.
- **`FlutterError.onError`** (framework/widget-build errors) and **`PlatformDispatcher.instance.onError`** (uncaught async errors outside the widget tree) are both wired at app startup (`core/`) to log the error and show a fallback UI — the app never shows a blank/frozen screen.
- **`ErrorWidget.builder`** is overridden to render a fallback widget in release builds — the default red error box stays for local development.
- **`logger`** package for all logging — leveled output instead of scattering `print()`/`debugPrint()` through the codebase.
