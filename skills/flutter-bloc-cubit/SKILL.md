---
name: flutter-bloc-cubit
description: This skill should be used when adding or reviewing state management in a Flutter feature, deciding between Cubit and full BLoC, modeling state/event classes, or writing bloc tests. This project standardizes exclusively on flutter_bloc — no Provider, Riverpod, or setState-driven business logic.
version: 0.1.0
---

# State Management: flutter_bloc (Cubit & BLoC)

## Cubit vs BLoC — the decision rule

**Use Cubit when:**
- State changes are triggered by direct method calls from the UI (e.g. `cubit.loadProfile()`).
- There's no need to react to a stream of external events beyond simple async calls.
- The flow is linear: call a method, emit a new state.

**Use full BLoC when:**
- State changes are driven by multiple distinct event types (user actions, stream updates, timers) that need explicit modeling.
- You need to debounce/throttle/transform a sequence of events (e.g. search-as-you-type).
- The flow benefits from being reasoned about as an event → transformation → state pipeline.

Default to Cubit; escalate to BLoC only when the event-driven complexity actually shows up. Don't reach for BLoC's event mapping machinery for something a Cubit method handles in three lines.

## State Modeling

- State classes are immutable and extend `Equatable` (or use `freezed` if already in the project) so `BlocBuilder` doesn't rebuild on equal states.
- Prefer a sealed/discriminated state shape (`Initial`, `Loading`, `Loaded(data)`, `Error(message)`) over a single mutable state class with nullable fields.
- Don't put UI-only concerns (e.g. a `TextEditingController`) inside Cubit/BLoC state — that belongs in the widget.

## BLoC Event Modeling

- One event class per user/system trigger, named as past-tense or imperative (`ProfileRequested`, `SearchQueryChanged`).
- Use `on<Event>` handlers with `emit.forEach`/`transformer` (e.g. `restartable()`, `droppable()`) for events needing debounce or cancellation — don't hand-roll this with `Future.delayed` timers.

## Wiring to Widgets

- `BlocBuilder` for pure rebuild-on-state UI.
- `BlocListener` for one-off side effects (navigation, snackbars) — never trigger side effects from `build()`.
- `BlocConsumer` when a widget needs both.
- Provide Cubits/BLoCs via `BlocProvider` at the narrowest scope that needs them — avoid app-wide providers for feature-local state.

## Testing

Use `bloc_test` for every non-trivial Cubit/BLoC:

```dart
blocTest<ProfileCubit, ProfileState>(
  'emits [Loading, Loaded] when loadProfile succeeds',
  build: () => ProfileCubit(mockRepository),
  act: (cubit) => cubit.loadProfile(),
  expect: () => [ProfileLoading(), ProfileLoaded(testUser)],
);
```

Cover: initial state, success path, failure path, and any debounce/cancellation behavior for BLoC event transformers.

## What NOT to do

- Don't use `Provider` or `Riverpod` — this project standardizes on `flutter_bloc` only.
- Don't drive business logic through `setState` in a `StatefulWidget`.
- Don't call repositories or use-cases directly from a widget — always through a Cubit/BLoC method.
