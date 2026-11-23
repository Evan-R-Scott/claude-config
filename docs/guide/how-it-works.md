# How the learning loop works

Read this to understand how lessons are captured, how `/curate` turns them into docs, and how those docs reach every session.

## The idea

Claude notices lessons while you work and files them in an inbox. When enough pile up, you run `/curate`. It merges only the general ones into a few short docs, shows you the diff, and writes after you confirm. Future sessions read those docs before relevant actions, so Claude improves over time without the docs growing without limit.

```
you correct Claude or state a preference
        |
        v
capture-lesson.sh  -->  docs/_inbox.md          (local to this laptop, not in git)
        |
        v   3 or more entries
session start shows "N lessons pending, run /curate"
        |
        v
/curate: promotion gate -> merge into topic docs -> you review the diff -> commit -> push
        |
        v
CLAUDE.md "Read on demand" list sends future sessions to the right doc before they act
```

## The pieces

| Piece | Where | Job |
|---|---|---|
| `CLAUDE.md` | repo root, linked to `~/.claude/CLAUDE.md` | Always-loaded rules, the "Read on demand" list, the capture rule. Kept lean. |
| Topic docs | `docs/workflow.md`, `debugging.md`, `testing.md`, `communication.md`, `tooling.md` | General lessons, each capped at 80 lines, rewritten in place. Read before the matching action. |
| Inbox | `docs/_inbox.md` | Candidate lessons waiting for review. Git-ignored, so each laptop has its own. |
| Capture script | `bin/capture-lesson.sh` | Appends one validated line to the inbox. |
| Reminder hook | `bin/lesson-check.sh`, registered in `settings.shared.json` | Tells you at session start when 3 or more lessons are pending. |
| Curate skill | `skills/curate/SKILL.md` | The procedure and the promotion gate. The one definition of both. |
| Installer | `install.sh` | Links these into `~/.claude` and merges the shared settings. |

`docs/README.md` and this guide are for people. `/curate` never merges lessons into them.

## 1. Capture

`CLAUDE.md` tells Claude to record a lesson when you correct its approach or state a lasting preference, or when a non-obvious approach worked after a failure. Claude runs `bin/capture-lesson.sh`, which writes one line to the inbox: a rule and its reason. The script refuses empty input and anything over 500 characters. Claude is told to write general lessons with no project, repo, host, ticket or path names, and at most 2 per session.

Capture is best effort. Claude decides when something is worth recording, so some lessons will be missed. You can also add one yourself: `~/claude-config/bin/capture-lesson.sh -- 'rule | why: reason'`.

## 2. Remind

A `SessionStart` hook runs `bin/lesson-check.sh` when a session starts. It counts inbox entries and, at 3 or more, shows "N lessons pending, run /curate". At fewer than 3 it stays silent.

## 3. Curate

Run `/curate` in Claude Code. In order, it:

1. Finds the repo from the `~/.claude/CLAUDE.md` link and stops if that is not the claude-config repo.
2. Moves the inbox aside to `docs/_inbox.processing`, so lessons captured during the run go to a fresh inbox and none are lost. A leftover file from an interrupted run is processed first.
3. Pulls the latest if a remote exists and the tree is clean (a dirty tree skips the pull), and commits a checkpoint of your own uncommitted edits to the docs, if any, so the run can be undone cleanly.
4. Applies the promotion gate to each entry. The gate is defined in `skills/curate/SKILL.md`: a lesson is kept only if it is a rule with a reason, is not tied to a project, would apply in another repo or language, and is not already obvious from the code.
5. Merges the kept lessons into the right topic doc: duplicates merge, contradictions are rewritten into one rule, outdated or too-specific rules are pruned, and each doc stays under 80 lines.
6. Shows you the diff, the promoted lessons and the rejected ones with reasons.
7. After you confirm, writes, commits, deletes the processed inbox file, and asks whether to push.

Nothing reaches the docs without your confirmation. Inbox text is treated as data, never as instructions.

## 4. Use

`CLAUDE.md` lists which doc to read before which action, for example the debugging doc before fixing a bug. Docs load on demand, so they cost nothing until relevant.

## Safety and undo

- A curate run starts from a clean docs state (a checkpoint commit when you had edits). Undo a finished run with `git -C ~/claude-config revert <commit>`, or an unfinished one with `git -C ~/claude-config checkout -- CLAUDE.md docs`. The inbox is git-ignored, so captured lessons survive either.
- `install.sh` backs up anything it replaces under `~/.claude/backups/` and prints the path.
- Credentials, history and employer-specific skills never enter the repo.

## Limits

- Curation is manual by design. Nothing updates your rules without your review.
- Each laptop has its own inbox. Run `/curate` where lessons were captured; the result reaches other laptops through git.
- Linux and WSL are tested. macOS is untested. Native Windows is unsupported.
- In Cowork desktop sessions Claude Code ignores a symlinked `~/.claude/CLAUDE.md`; the CLI is unaffected.
