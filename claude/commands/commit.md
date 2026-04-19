---
description: 変更をコミットする Sub Agent を起動する
---
Stage the files modified in this conversation using `git add`, then invoke the git-commit-agent skill.
Do NOT stage files unrelated to this conversation even if they appear in `git status`.

Rely on the conversation history to recall which files were touched and why — the skill runs in a forked context and will inspect `git status` / `git diff --cached` itself. Avoid reading git state in the main context unless the conversation history is insufficient to decide what to stage.

When invoking the skill, briefly tell it what you staged and why (1–2 lines), plus any ARGUMENTS from the user.

<ARGUMENTS>
$ARGUMENTS
</ARGUMENTS>
