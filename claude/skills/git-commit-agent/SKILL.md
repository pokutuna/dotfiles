---
name: git-commit-agent
description: |
  git の変更を分析し、conventional commit 形式でコミットを作成する。
context: fork
agent: general-purpose
model: sonnet
allowed-tools: Bash(git *)
---

Analyze the staged changes below and create a conventional commit.

## Git State

### git status
!`git status -s`

### git diff --cached (truncated to 300 lines)
!`git diff --cached | head -300`

### git diff --cached --stat
!`git diff --cached --stat | head -50`

**Note:** The diff above may be truncated. If you need more detail to understand the changes, run `git diff --cached` or `git diff --cached -- <file>` to inspect specific files.

### Recent commits
!`git log -5 --pretty=format:"%s"`

## Additional Context

$ARGUMENTS

## Instructions

### Staging Rules

**If already staged:** Proceed with ONLY the staged files. Do NOT add or modify staging.

**If nothing staged:** Report the situation and exit without committing.

**If mixed (some staged, some unstaged):** Commit ONLY the staged files. Do NOT auto-add unstaged changes.

### Staging Priority
1. Explicit user instructions
2. Files with logical cohesion
3. Recent completed work

### Commit Message

Infer language (Japanese/English) from recent commits above.

Create a commit message in `type(scope): subject` format with optional body. Scope is optional but infer from changes if clear.

**Types:**
- `feat`: New feature or significant addition
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code restructuring without behavior change
- `perf`: Performance improvements
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks, tooling, dependencies
- `deps`: Dependency updates
- `tweak`: Minor adjustments or improvements
- `nit`: Tiny fixes (typos, formatting)
- `wip`: Work in progress (use sparingly)

Choose the most significant impact if multiple types apply. Default to `chore` for miscellaneous updates.

**Subject:** Use inferred language, half-width chars, ≤50 chars, lowercase start (unless proper noun), no period, describe WHAT not HOW. Add spaces between Japanese and alphanumeric characters (e.g., "Pub/Sub を使った実装").

**Body:** Add only if needed to explain WHY or describe key changes. Don't try to explain everything - focus on the main points.

Do NOT modify staging. Commit only what is already staged.
