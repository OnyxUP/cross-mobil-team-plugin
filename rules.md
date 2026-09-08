# cross-mobil-team-plugin — Coding Discipline Rules

These rules complement the architectural standards in `CLAUDE.md` (Clean Architecture, `flutter_bloc`, Cloud Functions proxy). They are **binding** for every agent and contribution. Depth on individual topics lives in the linked skills; this file is the canonical, scannable source.

## 1. Single Responsibility (SRP)

- **One file = one job.** A file holds a single, coherent unit (one page, one widget, one Cubit/BLoC, one use-case, one repository, one datasource). Don't mix a page and its Cubit, or two unrelated widgets, in the same file.
- **One class = one reason to change.** If a class changes for two unrelated reasons, split it.
- Names describe the single responsibility. If you can only name a class/file with "and" or "manager/utils/helper" catch-alls, it's probably doing too much.

## 2. Component responsibilities — each does only its own job

| Component | Does ONLY | Never does |
|---|---|---|
| Page / widget (`presentation/pages`, `presentation/widgets`) | Layout, rendering, wiring UI to a Cubit/BLoC | Business logic, validation, I/O, HTTP, formatting/transforming data |
| Cubit / BLoC (`presentation/cubit` \| `bloc`) | Orchestrate state: call use-cases, emit states | Build widgets, hold `TextEditingController`s, do raw I/O, contain UI concerns |
| Use-case (`domain/usecases`) | One business operation via a single `call()` | Know about widgets, Firestore, HTTP, or DTOs |
| Repository interface (`domain/repositories`) | Declare the data contract in domain terms | Contain implementation or I/O |
| Repository impl (`data/repositories`) | Map DTOs↔entities, translate errors to failures | Contain UI or presentation logic |
| Datasource (`data/datasources`) | Raw I/O only (Cloud Function call, Firestore, cache) | Business rules, entity mapping decisions |

## 3. No logic in UI files

- Widgets are **declarative**. Callbacks (`onPressed`, `onChanged`, `onTap`, …) contain **no business logic** — each calls a **single Cubit/BLoC method** and nothing more.
- No inline anonymous functions that branch, validate, transform, compute, or perform I/O inside a widget or `build()`. If a callback needs more than "call one method", move that work into the Cubit/BLoC (or a use-case).
- No repository/use-case/datasource calls directly from a widget — always through a Cubit/BLoC method. See [`flutter-bloc-cubit`](skills/flutter-bloc-cubit/SKILL.md).
- No data formatting/filtering/sorting in `build()` — precompute in the Cubit/BLoC or memoize. See [`flutter-widget-review`](skills/flutter-widget-review/SKILL.md).

## 4. Pages must not be unnecessarily long

- A page's `build()` should read as **composition** — a tree of well-named sub-widgets, not a wall of nested inline widgets.
- Extract a subtree into its **own widget class** (in `presentation/widgets/`) once it grows, repeats, or holds its own state. Extract classes, not private `_buildX()` methods — method-"widgets" lose the `const` optimization and are harder to test.
- Soft smell threshold: a page file over **~200 lines** (or a single `build()` over ~150) usually signals extraction is overdue. This is a smell, not a hard cap — judgment applies.

## 5. SOLID principles (Flutter/Dart mapping)

- **S — Single Responsibility:** see §1–§2. Each file/class/function has one job.
- **O — Open/Closed:** extend behavior by adding a new use-case, widget, or datasource — not by piling conditionals into a growing god class or a mega `switch`.
- **L — Liskov Substitution:** a `data/` repository impl must fully honor its `domain/` interface contract (same nullability, error, and ordering semantics) so it's substitutable in tests and DI.
- **I — Interface Segregation:** keep abstract repositories narrow and role-specific. Prefer several focused interfaces over one fat interface a consumer only half-uses.
- **D — Dependency Inversion:** `presentation` and `domain` depend on **abstractions** (`domain` interfaces), never on concrete `data` classes. Wire concretes at the composition root via DI. See the DI section in [`clean-architecture`](skills/clean-architecture/SKILL.md).

## See also

- [`solid-separation-of-concerns`](skills/solid-separation-of-concerns/SKILL.md) — reviewer/author guidance for these rules.
- [`clean-architecture`](skills/clean-architecture/SKILL.md) — layering and the dependency rule.
- [`flutter-bloc-cubit`](skills/flutter-bloc-cubit/SKILL.md) — state management responsibilities.
- [`flutter-widget-review`](skills/flutter-widget-review/SKILL.md) — widget structure, `const`, performance.
