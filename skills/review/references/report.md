# Report formats (common rules)

Read this file and the template file for your target: `report-local.md` (local changes and files) or `report-pr.md` (pull request). The templates use the blocks below by name.

Output the complete report in full as your final message: every section, every finding, every checklist item. Never summarize, condense or omit a part (a section with nothing to say is one line; LOW findings beyond the 5 most important are given as a count). Severities: **[CRITICAL]** outage, breach or data loss, must fix. **[HIGH]** a real usage problem, should fix. **[MEDIUM]** meaningful risk or debt. **[LOW]** style or cleanup (a nit). Every finding has evidence of the kind its category needs (engine, Filter 3), with the command and result shown. There is no severity for guesses: what you could not verify goes under Not verified. A finding's Category is one of: Correctness, Security, Performance, Tests, Docs, Hygiene, Design. When there is nothing to review, the report is three lines (see the engine): the header, a line `Verdict: NO CHANGES`, and the `Report file:` line. A header is one of `## Local Review:`, `## PR Review:` or `## Review:`. Every report ends with the `Report file:` line the engine asks for.

## Finding block (used under **Findings** in every template)

```
**[SEVERITY] Category - Title**
`path/to/file.ext:line` or `path/to/file.ext:first-last` (repo-relative, never a scratch path; add `(base)` for a removed line)
> snippet

Evidence: the command and result (`(confirmed)`). Explanation: what is wrong or missing and why it matters; when the direction is obvious, end with a clause saying which way to fix it (no code), as part of the same sentence flow, not a separate labelled line.
```

## Documentation Assessment (used in every template)

Identify every doc file that needs to be created, updated, or deleted - whether or not the change already includes it. Missing items become findings. State what is missing, not the wording to add. For a pull request also include CLAUDE.md or AGENTS.md trigger changes if the PR introduces a new operational area agents should know to look up.

| Action | File | Repo | Section / detail |
|---|---|---|---|
| Create / Update / Delete | `docs/path/file.md` | repo-name | what needs to change and why |

## Checklist marks (used in every checklist)

Checklist marks never count toward INCOMPLETE; only the triggers in the Verdict section do. For a small change (about 20 changed lines or fewer) write the checklist grouped by mark, one line per mark (Verified: items with their evidence; Finding: items with the finding; Not verified; N/A with the reason), every item still named. "CI green" is N/A when no CI is configured (never Not verified). Mark each: **Verified** (with the command or tool output) / **Finding** (with a reference to it) / **Not verified** / **N/A** (with the reason, when the item does not apply). Reading alone is never Verified; never mark "looks good" without evidence.

## INCOMPLETE rules (the one definition, for every template's Verdict)

**INCOMPLETE - NEEDS HUMAN CHECK** (the same verdict in every template). Use it when any of these holds:

- a check the repo itself defines (its lint, type check or tests) could not run, for any reason including a missing tool or a harness denial;
- a high-risk group (auth, data access, infrastructure, migrations, public APIs, security) is under Not covered;
- a Not verified item is tagged `security` or `data-loss`.

It never triggers for: an optional scanner the repo does not use being unavailable; a check that does not apply (N/A); a repo that defines no checks; a change set with no executable code (comments, docs, config, CI pins); E4b logic testing that could not run on an untrusted target (a note in Verification Results); a low-risk group left unread (list it under Not covered in the Summary).

Exception: a repo check that CI ran and passed on exactly the reviewed head SHA (a pull request, or a pushed `--commit` or `--range`; not uncommitted changes) counts as run. Show it with `gh api --paginate repos/<owner>/<repo>/commits/<head-sha>/check-runs --jq '.check_runs[] | {name, conclusion, head_sha}'`, name which CI job matches which repo check, and write "by CI" in Verification Results. It is a signal, never evidence for a finding, and never covers a `security` or `data-loss` gap.

Precedence: the worst verdict (DO NOT COMMIT, DO NOT MERGE, DO NOT USE) > the fix verdict (FIX BEFORE COMMIT, REQUEST CHANGES, FIX BEFORE USE) > INCOMPLETE > the two good verdicts of the template. State INCOMPLETE's reasons in the Verdict line (also when a higher verdict outranks it, name any `security` or `data-loss` Not verified reasons there). Never post INCOMPLETE on a pull request as an approval.

## Re-check

When re-checking, add a section **Previously raised findings** (each: title, severity, `path:line`, Resolved / Still open / Not re-verified, one line on what you ran) before **Findings**, and call the second **New findings**.
