---
tags: [global, git]
---

# Git & PR Conventions

## Branching

- Two permanent branches: **`main`** (production-ready, deployable at all times) and **`dev`** (integration branch — where work lands before it's ready for `main`).
- All work branches off `dev`, never off `main`: `feature/<short-description>`, `fix/<short-description>`, `chore/<short-description>`.
- Work branches merge back into `dev` via PR. `dev` merges into `main` only when it represents a release/deployable state — never commit or merge directly into `main`.
- Hotfixes that can't wait for the normal `dev` → `main` flow are the only exception, and still go through a PR into `main` (then get merged back into `dev` immediately after, so the fix isn't lost on the next release).

## Commits

- Write commit messages in English, imperative mood ("add", "fix", "refactor" — not "added"/"adding").
- Conventional Commits prefixes: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `build`, `ci`.
- Subject line: what changed. Body (only when non-obvious): why — the motivation, constraint, or incident that drove the change, not a restatement of the diff.
- **Atomic commits**: one commit, one concern. If a commit's message needs "and" to describe it, it's two commits.
- **Only commit when explicitly asked, every time.** A previous approval doesn't carry over to the next change.
- **Never include `Co-Authored-By` (or any AI-attribution trailer) in commit messages** — the commit is authored under the developer's own identity, full stop.
- **Always check `.gitignore` — and what's actually staged — before committing.** Run `git status` first: build output (`bin/`, `obj/`, `build/`, `.dart_tool/`), real secrets (`appsettings.json`, `appsettings.Development.json`, `.env`), editor/IDE folders must never show up as staged.
- **`.env` and the two real `appsettings*.json` files are always listed in `.gitignore`, no exceptions** — only the documented template in the root `README.md` and `.env.example` are committed.
- **Keep `.gitignore` proactively up to date** — the moment a new tool, build step, or local config/cache folder shows up, add the entry right then.
- Never use destructive git operations (`--force`, `reset --hard`, amending pushed commits) without explicit confirmation.
- Never skip hooks (`--no-verify`) to work around a failing check — fix the root cause.

## Pull Requests

- PR title: short, imperative, under ~70 characters.
- PR description covers: what changed and why (not a line-by-line diff narration), plus a test plan / how it was verified.
- Keep PRs scoped to one concern. Split unrelated changes into separate PRs even if they were developed together.
- Before opening a PR: `dotnet build` + `dotnet format --verify-no-changes` + the backend test suite pass locally, and `flutter analyze` + the frontend test suite pass locally (whichever side the PR touches).

## Code review

See [code-review](code-review.md) for the review pass order, severity classification, and security checklist.
