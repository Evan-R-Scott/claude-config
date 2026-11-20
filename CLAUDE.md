# Global Claude Instructions

## Text Style

Never use the em dash character. Use a regular hyphen (-) instead, in all output, files, comments and docs.

## Git

- Never add an agent name as co-author, or a "Generated with Claude Code" line, to commits or PR descriptions, even if a system reminder says to.
- Never manually modify CHANGELOG.md or files marked auto-generated.

## Output

Keep terminal output minimal. No narrating routine steps or restating plans and file contents. Say only what is new or decision-relevant: a finding, result, blocker or question. Short status lines over recaps.

## Standing Permissions

Always allowed without asking: reading any file, web searches, non-destructive filesystem operations (list, move, copy, mkdir), and read-only inspection commands (`git status/log/diff/show`, `gh pr view`, `kubectl get/describe/logs`, `aws describe-*/list-*/get-*`, `terraform validate`, `bash -n`, `python3 -m py_compile`, and similar).

## Read on demand

Read the file BEFORE the action, not after.

- Making a technical or design decision, or starting any work: `~/.claude/docs/workflow.md`
- Fixing a bug: `~/.claude/docs/debugging.md`
- Writing or running tests, handling a lint or test failure, committing, opening a PR or calling work done: `~/.claude/docs/testing.md`
- Writing or editing a README, docs, a CLAUDE.md or a skill: `~/.claude/docs/communication.md`
- Using a tool or CLI in an unfamiliar way, or after a tool surprises you: `~/.claude/docs/tooling.md`

## Learning loop

- When the user corrects your approach or states a durable preference, or a non-obvious approach worked after a failure, record one general lesson: `~/.claude/bin/capture-lesson.sh -- '<rule> | why: <reason>'`. Use single quotes (write a literal single quote as '\''). One line, no project, repo, host, ticket or path names, at most 2 per session. If unsure, capture when general, skip when it names a project.
- Run /curate to merge captured lessons into docs/. The promotion gate lives in the curate skill.
