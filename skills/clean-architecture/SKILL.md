---
name: clean-architecture
description: This skill should be used when structuring a Flutter feature, deciding where code belongs (data/domain/presentation), designing a repository or use-case, or reviewing code for Clean Architecture layer violations.
version: 0.1.0
---

# Clean Architecture for Flutter

## Layering

Every feature lives under `lib/features/<feature_name>/` with three layers:

```
features/<feature_name>/
├── domain/
│   ├── entities/          # plain Dart classes, no framework deps
│   ├── repositories/      # abstract interfaces only
│   └── usecases/          # one class per use-case, single `call()` method
├── data/
│   ├── models/            # DTOs, `fromJson`/`toJson`, extend/map to entities
│   ├── datasources/        # remote (Cloud Functions/Firestore) and local (cache)
│   └── repositories/       # implements domain repository interfaces
└── presentation/
    ├── cubit/ or bloc/     # state management (see flutter-bloc-cubit skill)
    ├── pages/              # screen-level widgets
    └── widgets/            # reusable presentational widgets
```

## Dependency Rule

Dependencies only point inward: `presentation` → `domain` ← `data`. `domain` never imports from `data` or `presentation`. `presentation` never imports `data` directly — it only talks to `domain` (use-cases, entities) and gets concrete implementations wired via dependency injection.

**Violations to catch on review:**
- A widget or Cubit importing a `data/` model or datasource directly.
- A use-case importing a concrete repository implementation instead of the abstract interface.
- Business logic (branching, validation, calculations) living in a widget instead of a Cubit/use-case.

## Single Responsibility & SOLID

Layering only works if each unit does exactly one job: a widget renders, a Cubit/BLoC orchestrates state, a use-case performs one business operation, a repository defines/implements a data contract, a datasource does raw I/O. Business logic (branching, validation, calculation) never lives in a widget. This is the SOLID "S" and "D" applied to the layers; the full mapping and the "no logic in UI files" / "keep pages short" rules live in the `solid-separation-of-concerns` skill and `rules.md`.

## Repository Pattern

- `domain/repositories/x_repository.dart` declares an abstract class with methods returning domain entities (or `Either<Failure, T>` style results).
- `data/repositories/x_repository_impl.dart` implements it, translating datasource exceptions into domain-level failures and mapping DTOs to entities.

## Use-Cases

One class per use-case, named as a verb phrase (`GetUserProfile`, `SubmitOrder`), with a single public `call()` method taking a params object and returning a result. Use-cases orchestrate repository calls; they contain the only business logic in the domain layer.

## Dependency Injection

Wire concrete implementations (repositories, datasources) at the app's composition root (e.g. via `get_it` or constructor injection into Cubits), never inside the domain or presentation layers themselves.
