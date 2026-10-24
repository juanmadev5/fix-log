---
tags: [backend, aspnet-core, coding-standards]
---

# Coding Standards — ASP.NET Core

Additions to [engineering-principles](engineering-principles.md) specific to this stack.

## Naming

The callback/lambda-parameter rule applies to LINQ chains (`.Select`/`.Where`/`.GroupBy`).

```csharp
// Bad — meaning only recoverable by re-reading the surrounding types
var errors = validationException.Errors
    .GroupBy(e => e.PropertyName)
    .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());

// Good — each name says what the item is
var errors = validationException.Errors
    .GroupBy(validationError => validationError.PropertyName)
    .ToDictionary(
        propertyErrors => propertyErrors.Key,
        propertyErrors => propertyErrors.Select(validationError => validationError.ErrorMessage).ToArray());
```

## Control flow

Prefer **guard clauses** over nested conditionals — check failure/exit conditions first and return or throw immediately.

```csharp
// Bad — main logic buried inside nested conditions
public async Task<Report> ProcessAsync(Report? report)
{
    if (report != null)
    {
        if (report.CustomerId != Guid.Empty)
        {
            if (report.Status == ReportStatus.Pending)
            {
                return await _repository.SaveAsync(report);
            }
        }
    }
    throw new InvalidOperationException("Cannot process report");
}

// Good — guard clauses exit early, main logic is flat
public async Task<Report> ProcessAsync(Report? report)
{
    if (report is null) throw new ArgumentNullException(nameof(report));
    if (report.CustomerId == Guid.Empty) throw new InvalidOperationException("Report has no customer");
    if (report.Status != ReportStatus.Pending) throw new InvalidOperationException("Report is not pending");

    return await _repository.SaveAsync(report);
}
```

## No magic values

Closed sets of options use `enum`, per [engineering-principles](engineering-principles.md#no-magic-values).

## Comments

- Doc-comment format: `///`.
- Qualifies for a doc-comment: multi-step chains such as a `.Select().GroupBy().Aggregate()` pipeline; generic/abstract code (complex generics, reflection, expression trees, Strategy/Visitor-style patterns).

## Error handling

See [error-handling](error-handling.md#backend-aspnet-core).
