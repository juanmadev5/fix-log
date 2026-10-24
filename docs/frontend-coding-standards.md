---
tags: [frontend, flutter, coding-standards]
---

# Coding Standards — Flutter

Additions to [engineering-principles](engineering-principles.md) specific to this stack.

## Naming

The callback/lambda-parameter rule applies to `.map`/`.where`/`.fold`-style chains.

```dart
// Bad — meaning only recoverable by re-reading the surrounding types
final errorsByField = validationErrors
    .fold<Map<String, List<String>>>({}, (acc, e) {
  acc.putIfAbsent(e.field, () => []).add(e.message);
  return acc;
});

// Good — each name says what the item is
final errorsByField = validationErrors
    .fold<Map<String, List<String>>>({}, (accumulated, validationError) {
  accumulated.putIfAbsent(validationError.field, () => []).add(validationError.message);
  return accumulated;
});
```

## No magic values

Closed sets of options use Dart `enum`, per [engineering-principles](engineering-principles.md#no-magic-values).

## Architecture

The empty-folder rule also applies to a feature's `domain/use_cases/` — it isn't created until it gets its first file.

## Comments

- Doc-comment format: `///`.
- Qualifies for a doc-comment: multi-step chains such as a `.map().fold()` pipeline; generic/abstract code (complex generics, reflection-like patterns, Strategy/Visitor-style widgets).

## Error handling

See [error-handling](error-handling.md#frontend-flutter).
