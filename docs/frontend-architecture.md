---
tags: [frontend, flutter, architecture]
---

# Frontend Architecture — Flutter

## UI / Domain / Data (MVVM)

Three layers, dependencies always pointing downward, never upward:

```text
View → ViewModel (Cubit) → (Use-Case →) Repository → Service
```

- **UI layer** — `View` + `ViewModel`, one Cubit per View. Views (`widgets/`) are dumb: only layout, animation, simple conditionals, binding to Cubit state — no business logic, no data access except through the Cubit. The Cubit exposes state and **Commands** (callback methods for user interactions); it must be unit-testable without pumping a widget tree.
- **Domain layer** *(optional)* — `use_cases/`. Add one only when logic is genuinely complex, reused across more than one Cubit, or combines data from multiple repositories. Skip it otherwise — a Cubit is allowed to call a Repository directly. This project currently has no use cases — don't pre-create the folder until one is genuinely needed.
- **Data layer** — `Repository` + `Service`. A Repository (`data/repositories/`) is the single source of truth for one data type: it transforms raw/API models into domain models and is the only layer the Cubit talks to. A Service (`data/services/`) is a stateless wrapper around one external source (one feature's slice of the API) — it holds no state and makes no business decisions. UI and Domain depend on Repositories only, never on a Service directly.

Cardinality: View↔Cubit 1:1; Cubit→Repository/Use-Case many:1; Repository↔Service many:many; Repository→Repository never — combine data from two repositories in the Cubit or a Use-Case, not by having one repository call another.

```dart
// Data layer — Service: stateless wrapper, one external source, no business logic
class ReportApiService {
  ReportApiService(this._apiClient);
  final ApiClient _apiClient;

  Future<ReportApiModel> fetchById(String id) async { /* ... */ }
}

// Data layer — Repository: source of truth, owns transform, exposed as an abstract interface
abstract class ReportRepository {
  Future<Report> getById(String id);
}

class ReportRepositoryRemote implements ReportRepository {
  ReportRepositoryRemote(this._service);
  final ReportApiService _service;

  @override
  Future<Report> getById(String id) async {
    final apiModel = await _service.fetchById(id);
    return Report(id: apiModel.id, customerId: apiModel.customerId, cost: apiModel.cost); // raw -> domain
  }
}

// UI layer — Cubit as ViewModel: exposes state + Commands
class ReportDetailCubit extends Cubit<ReportDetailState> {
  ReportDetailCubit(this._repository) : super(ReportDetailInitial());
  final ReportRepository _repository;

  Future<void> loadCommand(String id) async {
    final report = await _repository.getById(id); // AppException maps to an error state, see error-handling.md
    emit(ReportDetailLoaded(report));
  }
}
```

### Folder organization — hybrid

The UI layer is organized **by feature** (vertical); `domain/` and `data/` are organized **by type** (layered):

```text
lib/
  ui/
    core/               # shared widgets, theme, strings
    auth/
    customer/
    expense/
    report/
    home/
      view_models/      # Cubit + its state
      widgets/
  domain/
    models/             # domain entities: Customer, Expense, Report, AuthResponse
    exceptions/         # AppException
  data/
    network/            # ApiClient (shared HTTP client)
    services/           # one adapter per feature against the API
    repositories/        # interface + implementation, source of truth per type
  core/                 # DI (GetIt), router (go_router), logger, global error boundary
```

## General principles

- **Dependency direction**: a Cubit or Use-Case never depends on Flutter widgets, and never depends on a `Service` directly — only on a `Repository`'s abstract interface. The `AuthRepository`, for example, is the one that decides to store the token in `ApiClient` after a successful login — `AuthCubit` doesn't know `ApiClient` exists.
- **Testability drives boundaries**: if logic can't be unit-tested without spinning up a real data source or the widget tree, the boundary is probably wrong.
- **Always depend on an interface, from the first implementation** — the four `Repository`s and four `Service`s in this app all get one from their first implementation, no carve-out for "there's only one implementation today."
- **Consistency within the project beats a "better" pattern mid-stream**: every feature follows the same split. Add a Domain layer for one feature only when that feature's logic actually warrants a Use-Case.

## Conventions

- File names: `snake_case.dart`. Classes: `PascalCase`. Members/variables: `camelCase`. Constants: `camelCase` — never inline literals.
- Widgets: prefer small, composable widgets over large `build()` methods. Extract a widget when a subtree has its own responsibility or is reused.
- Null-safety is mandatory; avoid `!` except where nullability has already been exhaustively proven earlier in the same scope.
- Enums: Dart `enum`s for closed sets of values, serialized with `.name`, never `.index`.

## Styling

No Tailwind (mobile, not web). A centralized theme (`ThemeData`, design tokens as constants, in `ui/core/`) instead of hardcoded colors/spacing scattered across widgets.

## State management

- **Cubit** (`flutter_bloc`) for every feature's ViewModel — this app's state so far is simple enough that a Cubit covers it with less ceremony than full Bloc.
- Reach for full **Bloc** only if a feature's state grows genuinely event-driven (multiple events, transitions, side effects worth modeling explicitly) — don't introduce that ceremony speculatively.
- States and events are modeled as sealed classes/unions, never raw strings/bools/enum-index checks.

## Dependency injection

**GetIt** as the service locator, registered at app startup in `core/` (per-feature registration modules, not one dumping-ground file).

## Navigation

**go_router** for all routing, including deep links and nested navigation.

## Internationalization (i18n)

**No i18n layer.** This app ships Spanish-only UI text — a deliberate, already-made decision, not an oversight. UI strings stay out of widget bodies (a `strings.dart`/similar constants file per [engineering-principles](engineering-principles.md#dry)) but are not routed through `flutter_localizations`/ARB files. If multi-language support is ever needed, that's a new explicit decision to make before starting the work, not something to retrofit silently — retrofitting i18n later means touching every widget again.

## Responsiveness

- Never design or implement a screen/component assuming one fixed viewport or device size — the realistic range (phone/tablet/desktop window, given this app also targets Windows/Linux) is in scope by default.
- Use `LayoutBuilder`/`MediaQuery` to adapt layout, never hardcoded pixel dimensions. This app's list/form screens already use `LayoutBuilder` to cap content width on large windows instead of stretching it edge to edge — follow that same pattern for new screens.
- Respect safe areas/system insets on mobile; don't assume portrait-only unless a screen has explicitly scoped out landscape.

## Error handling, logging, and testing

See [error-handling](error-handling.md#frontend-flutter) and [testing](testing.md#frontend-flutter).
