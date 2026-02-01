---
description: CLAUDE.md をベストプラクティスに基づいて改善する
---
# Improve CLAUDE.md

Analyze and improve the existing CLAUDE.md based on best practices from context engineering research.

## Background: Why This Matters

LLMs are stateless functions. They know absolutely nothing about your codebase at the beginning of each session. CLAUDE.md is the only file that goes into every single conversation, making it the highest leverage point of the harness.

**Critical insight**: Claude Code injects a system reminder telling Claude that CLAUDE.md content "may or may not be relevant" and to ignore it unless highly relevant. The more non-universal instructions you have, the more likely Claude will ignore your entire file.

## Step 1: Read Current CLAUDE.md

Read the existing CLAUDE.md file and analyze:

- Total line count
- Number of individual instructions (count imperative statements, bullet points with directives)
- Whether WHAT/WHY/HOW elements are covered

## Step 2: Evaluate Against Research-Based Criteria

### Instruction Count Limits

Research indicates:
- Frontier thinking LLMs can follow ~150-200 instructions with reasonable consistency
- Claude Code's system prompt already contains ~50 instructions
- This leaves only 100-150 instructions for CLAUDE.md, rules, plugins, skills, and user messages combined
- As instruction count increases, instruction-following quality decreases **uniformly** (not just newer instructions - ALL of them)
- Smaller models exhibit exponential decay; larger models exhibit linear decay

**Target**: Minimize instructions. Only include universally applicable ones.

### Length Guidelines

- General consensus: < 300 lines is best, shorter is better
- HumanLayer's own CLAUDE.md is < 60 lines
- All contents should be universally applicable to every session

### Content That Should NOT Be in CLAUDE.md

Identify and flag these for removal/separation:

1. **Task-specific instructions** - e.g., "how to structure a new database schema" - irrelevant when working on unrelated tasks
2. **Code style guidelines** - Never send an LLM to do a linter's job. LLMs are expensive and slow compared to deterministic tools. Use Hooks or Slash Commands instead.
3. **Code snippets** - They become out-of-date quickly. Prefer `file:line` references to point Claude to authoritative context.
4. **Hotfix-style instructions** - Instructions added to fix one-off behavioral issues that aren't broadly applicable
5. **Auto-generated content** - Output from `/init` or similar tools should be carefully reviewed and rewritten

### Required Elements (WHAT / WHY / HOW)

Verify these are present:

**WHAT** - Tell Claude about:
- The tech stack
- Project structure
- In monorepos: what the apps are, what shared packages are, what everything is for

**WHY** - Tell Claude:
- The purpose of the project
- What everything is doing in the repository
- The purpose and function of different parts

**HOW** - Tell Claude:
- How to work on the project (e.g., `bun` vs `node`)
- How to verify changes
- How to run tests, typechecks, and compilation steps

## Step 3: Apply Progressive Disclosure

Instead of stuffing everything into CLAUDE.md, leverage existing documentation in the repository.

**First, discover existing doc locations:**
- Search for directories like `docs/`, `documentation/`, `.github/`, `wiki/`, or markdown files
- Check for README files in subdirectories
- Identify architecture decision records (ADRs) or design docs

**Then, in CLAUDE.md:**
- Reference existing docs with brief descriptions
- Instruct to read relevant docs before starting work
- Only create new doc files if necessary information doesn't exist

**Key principle**: Prefer pointers to copies. Use `file:line` references, not code snippets.

## Step 4: Linting and Formatting Strategy

LLMs are in-context learners. If your code follows certain patterns, Claude should follow them naturally after searching the codebase.

Recommended approaches instead of style instructions in CLAUDE.md:
- Set up a Claude Code Stop Hook that runs formatter/linter and presents errors to Claude
- Use a linter that can auto-fix issues (e.g., Biome)
- Create a Slash Command for code review that points Claude at git changes

## Step 5: Generate Improved CLAUDE.md

Use this structure as a template:

```markdown
# Project Name

[1-2 sentences: project purpose]

## Tech Stack

- Language: 
- Framework: 
- Database: 
- Infrastructure: 

## Project Structure

[Brief description of directories, especially for monorepos]

## Essential Commands

- Build: `command`
- Test: `command`
- Typecheck: `command`
- Lint/Format: `command`

## Core Development Rules

[Only truly universal rules, 5-10 maximum]

## Documentation

Read relevant docs before starting work:

[List discovered doc files with brief descriptions]
```

## Output Format

Report in Japanese (日本語で報告):

1. **現状分析**: 行数、指示数、WHAT/WHY/HOWカバー状況
2. **問題点**: 削除・分離すべき項目
3. **改善後の CLAUDE.md**: 実際のファイル内容

## Remember

- CLAUDE.md is the highest leverage point - every line affects every session
- Don't try to stuff every possible command into the file
- Less is more: fewer instructions = better instruction-following across ALL instructions
- Claude will ignore CLAUDE.md if it decides contents aren't relevant to the current task
- Never auto-generate without careful review and rewriting
