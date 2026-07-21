---
name: commit
description: 変更をコミットする Sub Agent を起動する
---
Stage the files modified in this conversation using `git add`, then invoke the git-commit-agent skill via the Skill tool (NOT the Agent tool — the agent path re-judges staging without this conversation's context).
Do NOT stage files unrelated to this conversation even if they appear in `git status`.

After staging, verify with `git status --short` that everything you intended is fully staged: a failed pathspec aborts the whole `git add`, and a rename shows as `RM` when a later edit is left unstaged. Re-add anything missing before invoking.

Rely on the conversation history to recall which files were touched and why — the skill runs in a forked context and will inspect `git status` / `git diff --cached` itself. Avoid reading git state in the main context beyond the staging verification above unless the conversation history is insufficient to decide what to stage.

When invoking the skill, briefly tell it what you staged and why (1–2 lines), plus any ARGUMENTS from the user.

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>
