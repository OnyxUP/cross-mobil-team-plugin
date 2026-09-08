# cross-mobil-team-plugin — Project Rules

This project is a Flutter mobile application, and the following rules are binding for all agents and contributions.

## Architecture: Clean Architecture

Each feature is layered as `lib/features/<feature>/{domain,data,presentation}`. Dependency rule: `presentation` → `domain` ← `data`. `presentation` never imports `data` directly. See the `clean-architecture` skill for details.

## State Management: flutter_bloc (Cubit/BLoC)

This project uses **only `flutter_bloc`** — Provider, Riverpod, or `setState` driving business logic are forbidden. Use Cubit for simple, linear state; use BLoC for event-driven/multi-trigger flows. See the `flutter-bloc-cubit` skill for details.

## Backend: Proxy via Firebase Cloud Functions

Every request to a 3rd-party AI service or any external API is made **through a Firebase Cloud Function, never directly from the Flutter client**. The client never sees these services' API keys. See the `firebase-cloud-functions` skill for details.

## Coding Discipline (SRP / SOLID / Separation of Concerns)

Every file does exactly its own job. UI files (pages/widgets) contain **only UI code** — layout and wiring to a Cubit/BLoC; Cubit/BLoC, use-cases, repositories, and datasources each do only their own job. Widget callbacks call a **single** Cubit/BLoC method — no business logic, no inline logic functions, no direct repository/datasource calls in UI files. Pages stay short: extract sub-widgets into `presentation/widgets/` (own classes, not `_buildX()` methods) rather than growing one long page. All code follows **SOLID**. Full rules in `rules.md`; author/review guidance in the `solid-separation-of-concerns` skill.

## Motion / Animation

iOS screens use **Cupertino / iOS-style** animations (native page transitions with interactive swipe-back, iOS-standard durations and easing, opacity/scale press feedback over Material ripple). The `ui-ux-designer` specifies motion in every design spec; `flutter-developer` implements it using the patterns in the `design-system` skill.

## Test Expectations

- Every Cubit/BLoC is covered with `bloc_test` for at least success/error/initial states.
- Widget tests are written for critical screens' UI behavior.
- When a new Cloud Function is added, the related Firestore rules are updated in the same change.

## Using the Team

Always start work with `@mobile-lead` — it analyzes the task and delegates to the right specialist (`flutter-developer`, `backend-engineer`, `ui-ux-designer`, `security-engineer`, `aso-marketing`). Jumping straight to a specialist is only appropriate when the scope is already clear (e.g., ASO keyword research only).

## Naming Convention

- Files: `snake_case.dart`
- Classes: `UpperCamelCase`
- Cubit/BLoC state and event classes: subclasses rooted at `<Feature>State`, `<Feature>Event` (`<Feature>Loading`, `<Feature>Loaded`, ...)
