---
name: solid-separation-of-concerns
description: This skill should be used when writing or reviewing Flutter/Dart code for Single Responsibility, separation of concerns, and SOLID — keeping UI files free of business logic, each of page/widget/Cubit/BLoC/use-case/repository/datasource doing only its own job, and pages short by extracting widgets.
version: 0.1.0
---

# SOLID & Separation of Concerns

The canonical rule set is `rules.md` at the project root. This skill is the author/reviewer companion: how to apply the rules while writing, and what to catch on review.

## Single Responsibility

- One file = one job (one page, one widget, one Cubit/BLoC, one use-case, one repository, one datasource). Don't co-locate a page and its Cubit, or two unrelated widgets, in one file.
- One class = one reason to change. Split when a class changes for two unrelated reasons.
- Catch-all names (`Manager`, `Helper`, `Utils`, or anything you can only describe with "and") usually mark a responsibility that should be split.

## Responsibility matrix — each component does only its own job

- **Page/widget** — layout, rendering, and wiring UI to a Cubit/BLoC. No business logic, validation, I/O, HTTP, or data transformation.
- **Cubit/BLoC** — orchestrate state: call use-cases and emit states. No widget building, no `TextEditingController`s, no raw I/O, no UI concerns.
- **Use-case** — exactly one business operation via a single `call()`. Knows nothing about widgets, Firestore, HTTP, or DTOs.
- **Repository interface (domain)** — the data contract in domain terms.
- **Repository impl (data)** — map DTOs↔entities and translate errors to domain failures. No presentation logic.
- **Datasource (data)** — raw I/O only (Cloud Function call, Firestore, cache). No business rules.

## No logic in UI files

- Widget callbacks (`onPressed`, `onChanged`, `onTap`) call a **single** Cubit/BLoC method — nothing more.
- No inline anonymous functions that branch/validate/transform/compute/do I/O inside a widget or `build()`. Move that work into the Cubit/BLoC or a use-case.
- No repository/use-case/datasource calls from a widget — always via a Cubit/BLoC method.

## Keep pages short

- A page `build()` reads as composition — a tree of named sub-widgets, not deeply nested inline widgets.
- Extract a subtree into its **own widget class** in `presentation/widgets/` once it grows, repeats, or holds state. Extract classes, not `_buildX()` methods.
- Smell threshold: a page file over ~200 lines (or a `build()` over ~150) usually means extraction is overdue — a smell, not a hard cap.

## SOLID → Flutter/Dart

- **S** — Single Responsibility, as above.
- **O** — Open/Closed: extend via a new use-case/widget/datasource, not by growing conditionals in a god class or mega `switch`.
- **L** — Liskov: a `data/` repository impl fully honors its `domain/` interface contract (nullability, errors, ordering) so it's substitutable in DI and tests.
- **I** — Interface Segregation: narrow, role-specific abstract repositories over one fat interface.
- **D** — Dependency Inversion: `presentation`/`domain` depend on `domain` abstractions; wire concretes at the composition root (see the `clean-architecture` skill's DI section).

## Violations to catch on review

- Business logic (branching, validation, calculation, formatting) inside a widget, `build()`, or a callback.
- A callback doing more than calling one Cubit/BLoC method; a widget calling a repository/use-case/datasource directly.
- A Cubit/BLoC building widgets or holding UI controllers; a datasource making business decisions; a repository impl leaking DTOs to the domain.
- A page file that's a long wall of nested widgets instead of composed, named sub-widget classes.
- A concrete `data/` class imported by `presentation` or `domain` instead of a `domain` abstraction.
- A single class/file that clearly has more than one reason to change.
