---
name: design-system
description: This skill should be used when making theming, typography, spacing, or component-consistency decisions for the Flutter app, or when reviewing new UI against the existing design system.
version: 0.1.0
---

# Design System Consistency

## Tokens over literals

- Colors, spacing, and typography must come from the app's central `ThemeData`/token file (e.g. `lib/core/theme/`), never hardcoded hex values or magic numbers in widget code.
- Spacing follows a consistent scale (e.g. 4/8/12/16/24/32) — don't introduce one-off values like `13.5`.
- Typography uses the theme's `TextTheme` styles rather than ad-hoc `TextStyle(fontSize: ...)` calls.

## Extending vs. adding

Before introducing a new color, spacing value, or type style, check whether an existing token fits. Extend the token set only when there's a genuine, reusable need — not for a single screen's one-off look.

## Platform-appropriate patterns

- Use `Material` widgets/patterns on Android, `Cupertino` on iOS where platform conventions genuinely differ (navigation transitions, action sheets, date pickers). Don't force one platform's idioms onto the other without a product reason.
- Respect platform-specific safe areas and gesture conventions (e.g. iOS swipe-back).

## States every component must define

Any non-trivial screen/component design must specify: empty state, loading state, error state, and populated state — not just the "happy path" look.

## Accessibility baseline

- Minimum contrast ratio 4.5:1 for body text against its background.
- Minimum touch target ~48x48dp.
- Support system font scaling without clipping or overlap.
