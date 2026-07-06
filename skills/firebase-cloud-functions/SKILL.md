---
name: firebase-cloud-functions
description: This skill should be used when writing or reviewing Firebase Cloud Functions, proxying a 3rd-party AI or external API call, designing Firestore schema/security rules, or evaluating cost and quota controls for backend endpoints.
version: 0.1.0
---

# Firebase Cloud Functions (2nd gen)

## Why everything goes through Cloud Functions

The Flutter client never holds API keys for 3rd-party AI/external services and never calls them directly. Every such call is wrapped in a callable or HTTPS Cloud Function. This keeps secrets server-side, lets you enforce per-user quotas, and gives you a single place to control cost.

## Callable Function Pattern

```javascript
exports.generateSuggestion = onCall({ region: "europe-west1", secrets: ["AI_API_KEY"] }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }

  await enforceQuota(request.auth.uid, "generateSuggestion");

  const input = validateInput(request.data);

  const result = await callThirdPartyAI(input, process.env.AI_API_KEY);

  await logUsage(request.auth.uid, "generateSuggestion", result.usage);

  return sanitizeForClient(result);
});
```

Key points:
- Reject unauthenticated requests before doing any work.
- Validate/sanitize input before it reaches the external API — never forward raw client input untouched.
- Enforce a per-user quota/rate limit (Firestore counter or a dedicated rate-limit collection) before making the paid external call.
- Log usage for cost tracking.
- Strip upstream error details and internal identifiers before returning to the client — return a generic, safe error shape.

## Firestore Schema + Rules

Design the collection shape and its `firestore.rules` entry together, in the same change:

```
// Schema: /users/{uid}/requests/{requestId}
// { prompt: string, createdAt: timestamp, status: 'pending'|'done'|'error' }
```

```
match /users/{uid}/requests/{requestId} {
  allow read: if request.auth.uid == uid;
  allow write: if false; // only Cloud Functions (admin SDK) write here
}
```

Default posture: **deny by default**, grant the narrowest read/write needed. Client writes to sensitive collections (quota counters, AI request logs) should generally be `false` — only Cloud Functions using the Admin SDK write them.

## Cost & Quota Controls

- Track usage per user per function (e.g. `/users/{uid}/usage/{functionName}` with a daily/monthly counter) and reject calls once a quota is exceeded, before the external API is called.
- Set function-level `timeoutSeconds` and `memory` deliberately — don't leave defaults for functions calling slow external APIs.
- Prefer 2nd-gen functions (`onCall`/`onRequest` from `firebase-functions/v2`) for better concurrency and cost control over 1st-gen.

## Handoff to flutter-developer

Document each function's contract explicitly: function name, request shape, response shape, auth requirement, and error codes the client should handle. The client calls it via `FirebaseFunctions.instance.httpsCallable('functionName')` — it never needs to know what happens inside.
