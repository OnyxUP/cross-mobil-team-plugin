# cross-mobil-team-plugin

An end-to-end Claude Code plugin for Flutter mobile development: an agent team led by a senior mobile team lead, the skills those agents use, MCP integrations, and hooks aimed at reducing token cost. **Clean Architecture** is the architectural standard, **flutter_bloc (Cubit/BLoC)** is used for state management, and the backend is **proxied through Firebase Cloud Functions**.

## Quick Setup

Run the following commands, in order, from the directory containing the plugin folder (`cross-mobil-team-plugin`).

```sh
# 1) Add the plugin to Claude Code as a local marketplace.
#    <path-to-parent> = the parent directory THAT CONTAINS this folder (not the folder itself).
claude /plugin marketplace add <path-to-parent>
claude /plugin install cross-mobil-team-plugin

# 2) Enable the experimental Agent Teams feature for this project.
#    Creates .claude/settings.json at the project root (back up any existing file before overwriting).
mkdir -p .claude
cat > .claude/settings.json <<'EOF'
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "auto"
}
EOF

# 3) Define the environment variables the MCP servers need.
#    Add the real values to your own shell profile (.zshrc/.bashrc) or a .env manager,
#    never commit them to the repo.
export GITHUB_TOKEN="ghp_xxx..."                                  # for GitHub MCP
export FIREBASE_SERVICE_ACCOUNT_PATH="/path/to/service-account.json"  # for Firebase MCP

# 4) Make sure the hook scripts are executable
#    (permissions can sometimes reset when the repo is copied).
chmod +x hooks/*.sh hooks/token-savings/*.sh

# 5) Verify the setup: open a new chat in Claude Code and type:
#    @mobile-lead hello, introduce the team
```

The command names in step 1 may vary depending on your Claude Code version (`/plugin marketplace add` / `/plugin install` may appear as different subcommands in the current UI) — if unsure, type `/plugin` in Claude Code and use the "Add marketplace" / "Install plugin" flow in the UI; the result is the same.

---

## What Is Agent Teams?

This plugin is designed to use Claude Code's **experimental Agent Teams** feature (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, `teammateMode: "auto"`). With this mode on, agents can take on different roles relative to each other:

- **Manager (main context)**: `mobile-lead` stays in the main thread of the conversation, communicates directly with the user, and delegates work to specialist agents.
- **Teammate (isolated)**: The other 5 agents carry out their task in their own isolated workspace (see `isolation` below) and return the result to the manager — without polluting the manager's main context.

Each agent file's (`agents/*.md`) frontmatter contains these two experimental fields:

| Field | Values | Meaning |
|---|---|---|
| `isolation` | `none` / `worktree` | `none`: the agent runs in the main context (only `mobile-lead`). `worktree`: the agent works in isolation in its own git worktree copy and returns the result. |
| `memory` | `project` / `task` | `project`: the agent maintains an ongoing, project-wide memory (only `mobile-lead`). `task`: the agent's memory is scoped to that task and resets when the task ends. |

These two fields are not yet documented in Claude Code's official static documentation (experimental feature); while `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is off they remain harmless extra frontmatter, and agents continue to work normally.

---

## Team / Agents

| Agent | Role | Isolation | Memory | Tools |
|---|---|---|---|---|
| `mobile-lead` | Senior mobile team lead / manager | `none` (main context) | `project` | `*` (full access) |
| `flutter-developer` | Flutter/Dart implementation | `worktree` | `task` | Read, Write, Edit, Bash, Grep, Glob |
| `backend-engineer` | Senior Firebase backend | `worktree` | `task` | Read, Write, Edit, Bash, Grep, Glob |
| `ui-ux-designer` | Design decisions | `worktree` | `task` | Read, Grep, Glob, Write |
| `security-engineer` | Security audit | `worktree` | `task` | Read, Grep, Glob, Bash |
| `aso-marketing` | iOS ASO research | `worktree` | `task` | Read, Write, WebSearch, WebFetch |

Always start work with `@mobile-lead` — if the scope is already clear (e.g., just an ASO research task), you can also write directly to the relevant specialist.

### `mobile-lead` — Team Lead / Manager

Doesn't write code; analyzes the task, delegates to the right specialist, and reviews delivered work against Clean Architecture / flutter_bloc / Cloud Functions-proxy rules. Triggered by: new feature/bug requests, need for an architectural decision, work requiring multiple specialists (e.g., a new screen = design + Flutter code + Cloud Function), PR/work review requests. Delegation map: Flutter code → `flutter-developer`, Firebase/backend → `backend-engineer`, design → `ui-ux-designer`, security → `security-engineer`, ASO → `aso-marketing`.

### `flutter-developer` — Mobile Developer

Writes Flutter/Dart code across Clean Architecture's three layers (`domain`/`data`/`presentation`); uses Cubit/BLoC for state management. Triggered by: feature implementation, Flutter-side bug fixes, refactoring toward Clean Architecture, writing widget/bloc tests. Never calls a 3rd-party API directly — if such a need arises, it waits for/requests a Cloud Function from `backend-engineer`.

### `backend-engineer` — Senior Firebase Backend Engineer

Expert in Cloud Functions (2nd gen), Firestore schema/security rules, Auth, App Check, and Remote Config. Triggered by: 3rd-party AI/external service integration (always behind a Cloud Function), new Firestore collection/schema change, writing callable/HTTPS functions, Auth/access control changes. Updates Firestore rules in the same change as any schema change; flags `security-engineer` approval for any new public endpoint or loosened rule.

### `ui-ux-designer` — UI/UX Designer

Makes decisions on visual design, layout, theming, accessibility, and design-system consistency; doesn't write Dart code, produces a spec for `flutter-developer` to implement. Triggered by: new screen/flow design decisions, design-system consistency checks, accessibility reviews, Material/Cupertino platform decisions.

### `security-engineer` — Mobile Security Engineer

Audits mobile and backend security per OWASP MASVS (secure storage, certificate pinning, obfuscation, secret leakage, Firestore/Cloud Functions rules). Doesn't write fixes, produces a findings report and routes it to the relevant agent via `mobile-lead`. Triggered by: pre-commit/PR security scans, secure storage reviews, network security reviews, Firestore/Cloud Functions rules audits.

### `aso-marketing` — iOS ASO / Marketing

Produces App Store keyword research, competitor analysis, and listing copy (title/subtitle/keyword field) suggestions; doesn't touch the codebase. Triggered by: keyword research, competitor app analysis, listing copy drafts, localization-specific ASO needs. Respects Apple's character limits (title/subtitle 30, keyword field 100 characters).

---

## MCP Servers

3 servers are defined in `.mcp.json`; `pub.dev` hasn't been added yet since there's no stable official/community MCP server for it (see note below).

### `context7`

- **Purpose**: Real-time access to up-to-date Flutter/Dart/package documentation (package APIs may have changed/deprecated, model knowledge may be stale).
- **Used by**: Primarily `flutter-developer` and `backend-engineer`, and anyone needing current API/package documentation.
- **Type**: `http`, `https://mcp.context7.com/mcp`.
- **Setup**: No authentication needed, no extra steps.

### `github`

- **Purpose**: PR/issue workflow — opening PRs, reading/writing comments, issue tracking.
- **Used by**: `mobile-lead` (PR review/coordination), other agents as needed.
- **Type**: `http`, GitHub Copilot MCP endpoint, with an `Authorization: Bearer ${GITHUB_TOKEN}` header.
- **Setup**: Set the `GITHUB_TOKEN` environment variable to a Personal Access Token (with repo/issue permissions) (see Quick Setup step 3).

### `firebase`

- **Purpose**: Access to Firestore, Cloud Functions, Auth, Remote Config, Crashlytics.
- **Used by**: `backend-engineer` (primary), `security-engineer` (read-only, for Firestore rules audits).
- **Type**: `stdio`, `npx firebase-tools@latest experimental:mcp`.
- **Setup**: Set the `FIREBASE_SERVICE_ACCOUNT_PATH` environment variable to point to a Firebase service account JSON file's path (see Quick Setup step 3). Never commit this file to the repo.

### `pub.dev` (not yet added)

Once a stable official/community MCP server exists for package search/version info, it's recommended to add it to `.mcp.json`. Until then, `flutter pub outdated`/`flutter pub deps` commands and package documentation via `context7` are sufficient.

---

## Skills

| Skill | Summary | Used by |
|---|---|---|
| `clean-architecture` | Feature-first `domain`/`data`/`presentation` layering, dependency rule, repository/use-case patterns. | `flutter-developer`, `mobile-lead` |
| `flutter-bloc-cubit` | Cubit vs BLoC decision rule, state/event modeling, `bloc_test` patterns. Provider/Riverpod not used. | `flutter-developer` |
| `flutter-widget-review` | Widget rebuild performance, `const` correctness, accessibility. | `flutter-developer`, `ui-ux-designer` |
| `firebase-cloud-functions` | Writing Cloud Functions (2nd gen), 3rd-party AI/external API proxy pattern, Firestore schema+rules, cost/quota control. | `backend-engineer` |
| `design-system` | Theme/typography/spacing tokens, platform-specific patterns, accessibility baseline. | `ui-ux-designer` |
| `mobile-security-review` | OWASP MASVS-based checklist: secrets, secure storage, network security, Firestore/Cloud Functions audit. | `security-engineer` |
| `aso-keyword-research` | App Store keyword research methodology, competitor analysis, Apple character limits. | `aso-marketing` |

---

## Hooks

Defined in `hooks/hooks.json`, all scripts run via `${CLAUDE_PLUGIN_ROOT}`:

| Event | Matcher | Script | What it does |
|---|---|---|---|
| `SessionStart` | — | inline `echo` | Prints an info message at session start summarizing how to use the team and the project standards. |
| `PreToolUse` | `Read` | `hooks/token-savings/large-file-read-guard.sh` | If the file to be read is 500+ lines and no `limit` parameter is given, suggests using `offset`/`limit` or `Grep` instead of loading the whole file into context (returns feedback to the agent via `exit 2`). |
| `PostToolUse` | `Edit\|Write\|MultiEdit` | `hooks/layer-violation-check.sh` | If the modified `.dart` file is under `presentation/` and directly imports a `data/` module, warns of a Clean Architecture layer violation. |
| `PostToolUse` | `Bash` | `hooks/token-savings/bash-output-summarizer.sh` | If the output of commands like `flutter test`/`flutter analyze` exceeds 80 lines, writes the full log under `.claude/logs/` and returns to context only a summary containing `error`/`fail`/`warning` lines. |
| `PostToolUse` (only on `git commit`) | `Bash` + `if: Bash(git commit:*)` | `hooks/pre-commit-secret-scan.sh` | Scans the staged diff for hardcoded API key/token and debug `print()` patterns; returns a pre-commit warning if suspicious findings exist. |
| `Stop` | — | `hooks/token-savings/session-cost-log.sh` | Appends a timestamp to `.claude/logs/session-cost.log` when the session ends (a minimal, best-effort log for cost awareness). |

These hooks are heuristic pattern scans, not comprehensive static analysis tools — the final call always belongs to the relevant agent (especially `security-engineer`). Hooks that return `exit 2` stop the tool call and feed the message back for the agent to reconsider — it's guidance, not blocking.

---

## Project Standards

- **Clean Architecture** (`domain`/`data`/`presentation`, dependency rule pointing inward).
- **flutter_bloc** (Cubit + BLoC) — no Riverpod/Provider.
- **AI/external service proxy via Firebase Cloud Functions** — the client never sees a 3rd-party API key.

All rules are defined as binding in `CLAUDE.md`; agents and the related skills operate according to these rules.
