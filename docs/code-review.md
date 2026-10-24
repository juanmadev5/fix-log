---
tags: [code-review]
---

# Code Review

Rules for reviewing code in this repository — human reviewer or an agent.

## Review pass order

1. **Correctness** — does it do what it claims? Edge cases, null handling, off-by-one errors, incorrect conditionals.
2. **Security** — see [Security checklist](#security-checklist).
3. **Architecture/consistency** — does it respect the layer boundaries in [backend-architecture](backend-architecture.md)/[frontend-architecture](frontend-architecture.md)?
4. **Performance** — see [Backend](#backend-aspnet-core) / [Frontend](#frontend-flutter) below.
5. **Tests** — is coverage present where [engineering-principles](engineering-principles.md#testing) calls for it?
6. **Style** — lowest priority, never blocking on its own.

## Severity classification

- **Blocking**: correctness bugs, security vulnerabilities, magic values, duplicated logic, architecture-boundary violations, broken build/tests, missing error handling at a system boundary, missing per-resource authorization check.
- **Non-blocking (nit)**: naming preferences, micro-optimizations, suggested comments, pure style.
- A PR with only non-blocking comments can be approved; any blocking item requires changes before merge.

## Security checklist

Check every change against the current **[OWASP Top 10](https://owasp.org/Top10/2025/)** — fetch the page rather than relying on a remembered list. Record the lookup in `docs/SOURCES.md` if it actually shaped a finding.

At minimum, check for:

- Broken access control — missing or incorrect per-resource authorization. Every entity in this app (`Customer`, `Expense`, `Report`) is user-scoped: a query/update/delete must always filter by the authenticated user's id, including cross-entity relations (a `Report` can only point at a `Customer` the same user owns). Authentication alone is never enough.
- Sensitive data exposure — secrets, JWT secret, BCrypt work factor, tokens, or credentials hardcoded or logged.
- Missing input validation at a system boundary (a controller action, a Flutter form, an API response).

## Anti-patterns to always flag

- God classes/services/Cubits doing more than one thing.
- A domain entity (`Customer`, `Expense`, `Report`, `User`) or EF Core-mapped type leaking into a controller response, or a `data/` model leaking into a Flutter widget — see each stack's anti-pattern example below.
- Premature abstraction — extra internal splitting introduced with no real boundary or reason to change. This does **not** include an interface on an injected dependency — those are mandatory from the first implementation.
- Non-descriptive callback/lambda parameter names.
- An enum persisted/transmitted by ordinal instead of name.

## Comment format

- One comment per issue: location, the problem, the concrete fix. Don't narrate the whole diff back to the author.
- State the fix, don't just point out the problem.

## Self-review before opening a PR

- Read the full diff before requesting review.
- Confirm static analysis and the relevant test suite pass locally — see [git-conventions](git-conventions.md#pull-requests).

## Approve / request changes

- Any blocking item open → request changes.
- Only non-blocking comments left → approve, comments optional to address.
- Nothing outstanding → approve.

## Backend (ASP.NET Core)

**Performance**: N+1 EF Core queries, unnecessary allocations, unpaginated large payloads.

**Security, on top of the checklist above**: SQL injection (unparameterized queries — EF Core's parameterized LINQ already protects against this when used correctly, flag any raw SQL that isn't), CSRF/CORS misconfiguration (check `CorsSettings:AllowedOrigins` isn't loosened to `*` outside local dev).

```csharp
// Bad — EF Core entity returned straight from the API
[HttpGet("{id}")]
public async Task<Customer> Get(Guid id) => await _dbContext.Customers.FindAsync(id);

// Good — a DTO shaped for the API contract, decoupled from the persistence model
[HttpGet("{id}")]
public async Task<CustomerResponse> Get(Guid id)
{
    var customer = await _customerRepository.GetByIdAsync(id, currentUserId);
    return new CustomerResponse(customer.Id, customer.Name, customer.Email);
}
```

## Frontend (Flutter)

**Performance**: unnecessary rebuilds, unbounded lists without pagination/lazy loading, heavy work on the UI thread.

**Security, on top of the checklist above**: secrets/tokens stored in plain `shared_preferences` instead of secure storage; secrets embedded in a request URL.

```dart
// Bad — a data-layer model returned straight to the widget tree
class CustomerScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final customer = customerDataSource.fetchCustomer(id); // raw API model
    return Text(customer.email);
  }
}

// Good — the Cubit's state carries a domain model, decoupled from the data-layer model
class CustomerDetailState {
  final Customer customer; // domain/models/customer.dart
  CustomerDetailState({required this.customer});
}
```
