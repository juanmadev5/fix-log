---
tags: [testing]
---

# Testing

How a test is written once it's warranted — *when* a test is mandatory is in [engineering-principles](engineering-principles.md#testing).

## Structure — Given-When-Then

- Every test reads as Given → When → Then, and its body is split into three commented blocks in that order (`// Given`, `// When`, `// Then`), replacing generic Arrange/Act/Assert labels.
- One test per scenario — don't cram multiple Given/When combinations and several unrelated assertions into a single test.

## Mocking policy

- **Mock every injected dependency in a unit test** — repositories, services, external clients, clock/time providers. A unit test never touches a real database, network call, or filesystem.
- Integration tests are the ones that exercise real infrastructure — they trade mock isolation for confidence that the actual EF Core mapping and DbUp-applied Postgres schema behave correctly. Don't mix the two styles in the same test class.
- Widget tests assert on what the user actually sees (rendered text, roles) for a given state — never on private state/internal fields a refactor could change without changing behavior.

## What to test

- Prefer testing through the public API of a class/service/Cubit, not its private implementation details.

## Backend (ASP.NET Core)

- **Stack**: **xUnit** as the test runner, **Moq** for mocking, and xUnit's own `Assert` for assertions — **no separate assertion library**. `FluentAssertions` is specifically excluded: versions 8+ require a commercial license (see [dependency-management](dependency-management.md)), and this repo's default is to never carry that risk, even on a version that's currently free.
- **Testcontainers** (`Testcontainers.PostgreSql`) for integration tests that need a real Postgres — never a shared manual-dev instance. Each integration test class spins up its own ephemeral container.
- Test method names: `Given_<context>_When_<action>_Then_<outcome>`.

```csharp
[Fact]
public async Task Given_ReportBelongsToAnotherUser_When_GetById_Then_ThrowsNotFoundAppException()
{
    // Given
    var repositoryMock = new Mock<IReportRepository>();
    repositoryMock.Setup(r => r.GetByIdAsync(reportId, otherUserId)).ReturnsAsync((Report?)null);
    var sut = new ReportService(repositoryMock.Object, customerRepositoryMock.Object);

    // When
    var act = () => sut.GetByIdAsync(reportId, otherUserId);

    // Then
    await Assert.ThrowsAsync<NotFoundAppException>(act);
}
```

- Constructor-injected dependencies are mocked with Moq. Integration tests verify the actual EF Core mapping and DbUp-applied schema against real Postgres via Testcontainers.

## Frontend (Flutter)

- **Stack**: `flutter_test` for unit and widget tests, **mocktail** for mocking, **`bloc_test`** for testing Cubit state transitions.
- Nested with `group`, the expectation in the innermost `test`:

```dart
group('given a report with no customer', () {
  group('when submitting the form', () {
    test('then emits a validation error state', () {
      // Given
      final repositoryMock = MockReportRepository();

      // When
      // ...

      // Then
      // ...
    });
  });
});
```

- For a Cubit, `bloc_test`'s own `blocTest(...)` already expresses Given-When-Then structurally (`build`/`seed` = Given, `act` = When, `expect` = Then) — use its built-in shape instead of nesting `group`/`test` manually.
- Dependencies arrive via constructor/GetIt injection. Widget tests use `pumpWidget` with mocked Cubits provided via `BlocProvider`; the Cubit's own state logic has its own unit test.

## Sources

Record any testing-library API verified against official docs in `docs/SOURCES.md` per [backend-sources](backend-sources.md) / [frontend-sources](frontend-sources.md).
