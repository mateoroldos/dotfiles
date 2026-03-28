---
name: repo-librarian
description: "Build and use a local reference library of remote git repositories. Cache repos, refresh them safely, search source, analyze architecture, extract patterns, and compare implementations across projects. Use when the user mentions a GitHub/GitLab/Bitbucket repo, asks for examples from real projects, or wants implementation patterns from external codebases."
---

# Repo Librarian

Use this skill when the user:

- Points to a remote git repository, including GitHub/GitLab/Bitbucket URLs, `git@...`, or `owner/repo` shorthand.
- Wants ideas, patterns, architecture examples, or conventions from real projects.
- Asks to compare how multiple repos solve a problem.
- Asks to search or analyze previously referenced repos.

The goal is to maintain a reusable local reference library of repositories that is:

- **Stable**: predictable checkout paths.
- **Current**: throttled fetch and safe fast-forward updates.
- **Efficient**: partial clones using `--filter=blob:none`.
- **Useful**: searchable, taggable, and summarized with reusable notes.
- **Cited**: analysis should reference concrete files and paths.

## Storage layout

Checkouts live at:

```txt
~/.cache/checkouts/<host>/<org>/<repo>
```

Repo Librarian metadata lives at:

```txt
~/.cache/repo-librarian/index.tsv
~/.cache/repo-librarian/notes/<host>/<org>/<repo>.md
```

## Core commands

Resolve, clone, refresh, and print the local checkout path:

```bash
bash .pi/skills/repo-librarian/scripts/checkout.sh <repo> --path-only
```

Examples:

```bash
bash .pi/skills/repo-librarian/scripts/checkout.sh mitsuhiko/minijinja --path-only
bash .pi/skills/repo-librarian/scripts/checkout.sh github.com/mitsuhiko/minijinja --path-only
bash .pi/skills/repo-librarian/scripts/checkout.sh https://github.com/mitsuhiko/minijinja --path-only
```

List cached repos:

```bash
bash .pi/skills/repo-librarian/scripts/list.sh
```

Search one repo:

```bash
bash .pi/skills/repo-librarian/scripts/search.sh vercel/next.js "defineConfig"
```

Search all cached repos:

```bash
bash .pi/skills/repo-librarian/scripts/search-all.sh "defineConfig"
```

Analyze one repo and create/update a reusable note:

```bash
bash .pi/skills/repo-librarian/scripts/analyze.sh vercel/next.js
```

Tag a repo:

```bash
bash .pi/skills/repo-librarian/scripts/tags.sh add vercel/next.js react framework typescript
bash .pi/skills/repo-librarian/scripts/tags.sh list vercel/next.js
```

## Recommended workflow

1. Resolve every mentioned remote repo with `checkout.sh --path-only` before reading it.
2. Start analysis from manifests and structure: README, package manifests, config files, examples, tests, and top-level directories.
3. Use `rg`, `fd`, `git grep`, and focused reads instead of browsing randomly.
4. Save durable discoveries with `analyze.sh` or by editing the generated note.
5. When reporting patterns, cite exact files and explain why the pattern is reusable.
6. When comparing repos, inspect equivalent files or directories across each repo before synthesizing.

## Pattern report standard

When extracting ideas from repos, answer in this shape:

```md
## Pattern
<short name>

## Why it matters
<what problem it solves>

## Evidence
- `<repo>/<path>` — <what this file shows>
- `<repo>/<path>` — <what this file shows>

## How to adapt it here
<practical recommendation for the user's project>

## Tradeoffs
<costs, constraints, or when not to use it>
```

## Safety rules

- Do not edit files directly inside `~/.cache/checkouts`.
- If task-specific edits are needed, create a separate worktree or copy.
- Prefer fast-forward updates only. Do not reset or discard local changes automatically.
- Treat external code as reference material, not as code to copy blindly. Preserve licenses and attribution when relevant.

## Repo reference parsing

Supported inputs include:

- `owner/repo` → defaults to `github.com`.
- `github.com/owner/repo`.
- `https://github.com/owner/repo`.
- `git@github.com:owner/repo.git`.
- Similar GitLab/Bitbucket HTTPS and SSH forms.
