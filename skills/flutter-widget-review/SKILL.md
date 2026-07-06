---
name: flutter-widget-review
description: This skill should be used when writing or reviewing Flutter widgets for rebuild performance, const-correctness, and accessibility.
version: 0.1.0
---

# Flutter Widget Review

## Performance

- Mark widgets/constructors `const` wherever their inputs are compile-time constant — this lets Flutter skip rebuilding them entirely.
- Scope `BlocBuilder`/`ValueListenableBuilder`/`AnimatedBuilder` as narrowly as possible around the subtree that actually needs to rebuild; don't wrap an entire page when only a small widget changes.
- Prefer `ListView.builder`/`SliverList` over building all children eagerly for any list that can grow.
- Avoid expensive work (formatting, filtering, sorting) inside `build()` — compute it in the Cubit/BLoC or memoize it.

## Accessibility

- Every interactive element needs a minimum touch target of ~48x48dp.
- Provide `Semantics`/`semanticLabel` for icon-only buttons and images that convey meaning.
- Respect system text scaling — avoid fixed-height containers that clip text at larger accessibility font sizes.
- Check color contrast against the project's `design-system` tokens, not ad-hoc colors.

## Structure

- Extract a widget into its own class (not just a method) once it has meaningful internal state or is reused — method-based "widgets" don't get the `const` optimization and complicate testing.
- Keep widget files focused: one primary widget per file, private helper widgets colocated only if small and single-use.
