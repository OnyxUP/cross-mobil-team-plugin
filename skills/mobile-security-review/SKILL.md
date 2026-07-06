---
name: mobile-security-review
description: This skill should be used when auditing Flutter app or Firebase backend code for security issues — secret handling, secure storage, network security, and Firestore/Cloud Functions access control — aligned with OWASP MASVS.
version: 0.1.0
---

# Mobile Security Review (OWASP MASVS-aligned)

## Secrets

- No API keys, tokens, or credentials hardcoded in Dart source, `.env` files committed to the repo, or Firestore documents readable by the client.
- 3rd-party AI/external API keys live only in Cloud Functions secret config (`firebase functions:secrets:set` or Secret Manager), never shipped to the client.
- Grep for common leak patterns before every commit: `sk-`, `AIza`, `Bearer `, `api_key`, `apiKey =`, hardcoded URLs with embedded credentials.

## Secure Storage

- Tokens, session data, and PII stored on-device must use `flutter_secure_storage` (Keychain on iOS, Keystore-backed on Android) — not `SharedPreferences` or unencrypted `sqflite` for sensitive fields.
- Cache only what's necessary; don't persist full API responses containing PII longer than needed.

## Network Security

- All network calls use TLS; no cleartext HTTP endpoints.
- Certificate pinning is warranted for high-value endpoints (auth, payment, sensitive data) — evaluate case by case, not blanket-applied if it complicates cert rotation without a clear threat model reason.

## Firestore Rules Audit

- Default-deny: every collection has an explicit rule; nothing relies on the absence of a rule.
- Least privilege: `allow write` scoped to the owning user (`request.auth.uid == resource.data.ownerId`), not broad `if request.auth != null`.
- Collections written only by Cloud Functions (Admin SDK bypasses rules) should have client `write: false`.

## Cloud Functions Audit

- Every callable/HTTPS function checks `request.auth` before doing paid or sensitive work.
- Input is validated/sanitized before use — no unvalidated input forwarded to an external API or used in a Firestore query without bounds.
- Error responses returned to the client don't leak stack traces, internal identifiers, or upstream provider error bodies.

## Obfuscation

- Release builds use `flutter build --obfuscate --split-debug-info=<dir>` when the app contains business logic worth protecting from reverse engineering.

## Findings Format

Report each finding as: location, the concrete issue, a realistic exploit/failure scenario (not just "this is bad practice"), and severity. Skip stylistic nitpicks that have no security impact.
