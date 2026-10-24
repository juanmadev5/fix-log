---
tags: [global, engineering-principles]
---

# Engineering Principles

Rules that apply to every part of this repository, backend and frontend alike. [backend-coding-standards](backend-coding-standards.md) and [frontend-coding-standards](frontend-coding-standards.md) only add what's specific to each stack (code examples, doc-comment syntax, tooling) and never contradict this note.

## Language

- All code, identifiers, comments, commit messages, and documentation are written in **English**.
- The only exception is text that is user-facing in the Flutter UI (labels, messages, validation text), which is Spanish — this app has no i18n layer (see [frontend-architecture](frontend-architecture.md#internationalization-i18n)).
- **URLs are not user-facing text.** Route paths, API path segments, query-parameter names, and navigation/route constants are always English — `/api/v1/customer`, `GoRouter` route names — even though the UI itself is in Spanish.
- Backend error codes (`CUSTOMER_NOT_FOUND`, `EMAIL_ALREADY_REGISTERED`, ...) are English constants; only the Flutter-side text shown to the user for a given code is Spanish.

## Naming

- Every identifier must be understandable **at first glance**, with no need to trace back through the code to figure out what it represents. This includes variables, parameters, and — just as strictly — **callback/lambda parameters** in collection, stream, and reactive chains (LINQ in C#, `.map`/`.where`/`.fold` in Dart).
- Never name a callback parameter after a generic placeholder letter (`e`, `x`, `el`, `arr`) when a descriptive name is one keystroke away.
- The one broadly accepted exception is a raw numeric index in a tight loop (`i`). Everything else — including nested callback parameters shadowing an outer one — gets a real, descriptive name.
- Avoid generic, content-free names (`data`, `result`, `item`, `obj`, `temp`) whenever a name that describes what the value represents is available — `pendingReport`, not `report`, once there's more than one report-shaped value in scope.
- See [backend-coding-standards](backend-coding-standards.md#naming) and [frontend-coding-standards](frontend-coding-standards.md#naming) for bad/good examples in each language.

## No magic values

- Never inline literal strings or numbers that carry meaning (error codes, claim types, config keys, route paths, storage keys, cache keys, etc.).
- Always extract them to named constants, or to an enum/`enum` when the value represents a closed set of options.
- When persisting or transmitting an enum (DB, JSON, local storage, query params), always use its **name**, never its ordinal/index/numeric value. Ordinals silently break when a member is added, removed, or reordered; names are stable and self-documenting across the backend/Flutter boundary. This repo already does this correctly on the backend (`JsonStringEnumConverter`) — keep it that way for every new enum.

## DRY

- Duplication is a defect, not a style preference. If the same logic (not just similar-looking code) appears more than once, extract it.
- DRY applies to logic and business rules, not to superficial structural similarity. Don't force an abstraction over code that merely looks alike but represents different concerns.
- The pagination envelope, its default/max page size, and its query-param names are a single shared type in `Application` (backend) — never redefined per feature. See [backend-architecture](backend-architecture.md#pagination--filtering).

## SOLID

Applied together with DRY, not instead of it.

- **Single Responsibility**: a class/service/widget/Cubit has one reason to change. If describing what it does requires "and", it's a candidate to split.
- **Open/Closed**: extend behavior by adding new code (a new validator, a new repository implementation, a new Cubit state), not by modifying working code to special-case a new scenario.
- **Liskov Substitution**: an implementation must be usable anywhere its interface is expected, with no caller type-checking or special-casing a concrete type.
- **Interface Segregation**: prefer several small, focused interfaces over one large one (`ICustomerRepository`, not one `IRepository` god-interface).
- **Dependency Inversion**: business logic (`Application` services, Flutter ViewModels/Use-Cases) depends on abstractions, never on concrete infrastructure. Every injected dependency gets an interface/abstract class from its first implementation — this is not premature abstraction, it's what makes the class unit-testable at all.

Apply these pragmatically: a guide for keeping code changeable, not a checklist to satisfy for its own sake. Don't split a class or add indirection with no real boundary or reason to change.

## Architecture

- The default architecture for each side of this repo is fixed — Clean Architecture for the backend, UI/Domain/Data (MVVM) for Flutter — see [backend-architecture](backend-architecture.md) and [frontend-architecture](frontend-architecture.md). It is not a per-feature choice.
- **Never create a folder that ends up empty.** A folder is added at the moment it gets its first real file, never pre-scaffolded "for later" — this applies to a backend layer's subfolder and to a Flutter feature's `domain/use_cases/` alike.
- Don't pre-create a feature's full folder tree before there's a file to put in each one.

## Comments

- Default to no comments. Code should be self-explanatory through naming. This stays the default for trivial code — getters, direct mappings, anything a well-named signature already explains.
- Write a comment when it captures a **non-obvious why**: a hidden constraint, a workaround for a specific bug/API quirk, a business rule that isn't derivable from the code itself.
- **Exception**: a short doc-comment above a function (`///` in both C# and Dart) when it's genuinely complex enough that a competent reader can't infer its purpose from the name + signature + a read of the body alone:
  - Recursive logic or non-trivial algorithms.
  - Multi-step chains of higher-order functions (a `.Select().GroupBy().Aggregate()` or `.map().fold()` pipeline).
  - Generic/abstract code (complex generics, reflection, Strategy/Visitor-style patterns).
  - Rule of thumb: if describing what the function does in one sentence needs more than 2-3 chained steps, or the name doesn't communicate *how* it achieves its result, it qualifies. 1-3 lines, summarizing purpose and approach — never a line-by-line narration, and never a comment inside the function body for this case.

## Error handling

- Validate and handle errors at system boundaries (controller input, HTTP responses from the API inside the Flutter data layer, I/O). Don't add defensive checks for states already impossible given internal invariants.
- Fail loudly in development; degrade gracefully (with proper logging) in production paths that face end users.
- See [error-handling](error-handling.md) for the concrete mechanism on each side.

## Definition of done

A task is never "done" just because it behaves correctly or compiles. Before considering any task/feature finished:

- **Static analysis** — `dotnet build` + `dotnet format --verify-no-changes` clean on the backend, `flutter analyze` clean on the frontend, no new warnings introduced by the change.
- **Tests** — pass locally; new tests written when the change touches logic covered by [Testing](#testing) below (see [testing](testing.md)).
- **Self-review** — the full diff was read start to finish before calling the task done, per [code-review](code-review.md)'s self-review section.
- **Docs** — the root `README.md` was updated if the change affects it; `docs/SOURCES.md` was updated if a source not already covered by [backend-sources](backend-sources.md)/[frontend-sources](frontend-sources.md) was consulted (create `docs/SOURCES.md` the first time it's actually needed — not before).
- **Scope check** — the change matches exactly what was asked, no unrelated edits left in.
- **No residue** — no leftover debug code, commented-out blocks, or unowned TODOs.

## Testing

- Tests are **not a blanket requirement for every change.** Writing tests for a trivial CRUD wrapper or low-stakes glue code is its own form of over-engineering.
- Tests **are mandatory** for business logic that's genuinely delicate and error-prone: authorization/resource-ownership checks (every entity in this app is user-scoped — see the root README's "Autorización por recurso"), money/cost calculations on reports and expenses, auth (`AuthService`, JWT/BCrypt), and any state transition where a silent bug would leak one user's data to another or corrupt stored data.
- The judgment call: "if this breaks silently, how bad is it?" — if the honest answer involves a user seeing another user's data, a report/expense total being wrong, or a failed login behaving insecurely, it needs tests. If the worst case is "a list renders in the wrong order," it probably doesn't.
- See [testing](testing.md) for structure and mocking conventions.

## Scope discipline

- Implement what the task requires. Don't add speculative flexibility, extra config options, or abstractions for hypothetical future needs.
- No half-finished implementations: either a feature is complete for its intended scope, or it isn't started.

## Ask vs. assume

- **Ask, and don't proceed until answered**, when: the decision is business/domain-specific and not inferable from the existing code or this repository; multiple reasonable interpretations exist with materially different outcomes (breaking vs. additive API change, the shape of a data model). Check this `CLAUDE.md` and `/docs/` first — don't ask what's already documented there.
- **Decide and proceed**, when: it's a routine implementation detail with one obviously-correct answer given the codebase's existing patterns; it's already resolved by a note in `/docs/` or `CLAUDE.md`.
- **Never guess an API, method, or parameter** that hasn't been verified against real code or official documentation (see [backend-sources](backend-sources.md) / [frontend-sources](frontend-sources.md)).
- If proceeding on a judgment call rather than asking, state the assumption explicitly instead of deciding silently.
