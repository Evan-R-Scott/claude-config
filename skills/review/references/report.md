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

Checklist marks never count toward INCOMPLETE; only the triggers in the Verdict section do. Mark each: **Verified** (with the command or tool output) / **Finding** (with a reference to it) / **Not verified** / **N/A** (with the reason, when the item does not apply). Reading alone is never Verified; never mark "looks good" without evidence.

## INCOMPLETE rules (the one definition, for every template's Verdict)

**INCOMPLETE - NEEDS HUMAN CHECK** (the same verdict in every template). Use whenever the target was untrusted and it has code whose repo checks (E4a) could not run, a check the repo defines could not run (but see the exceptions below), a high-risk area is under Not covered, or a Not verified item is tagged `security` or `data-loss`. Order of precedence: the worst verdict (DO NOT COMMIT, DO NOT MERGE, DO NOT USE) > the fix verdict (FIX BEFORE COMMIT, REQUEST CHANGES, FIX BEFORE USE) > INCOMPLETE > the two good verdicts of the template. State INCOMPLETE's reasons in the Verdict line (also when a higher verdict outranks it, name any `security` or `data-loss` Not verified reasons there). For a pull request, never post INCOMPLETE as an approval. An optional scanner the repo does not use being unavailable, or a check that does not apply (N/A), never triggers it. A check the repo itself defines (its lint, type check or tests) that could not run, for any reason including a missing tool, does. Exceptions: a change set with no executable code (comments, docs, config, CI pins) never triggers the "could not run" reasons; a repo check that CI ran and passed on exactly the reviewed head SHA (a pull request, or a pushed `--commit` or `--range`; not uncommitted changes) counts as run (show it with `gh api --paginate repos/<owner>/<repo>/commits/<head-sha>/check-runs --jq '.check_runs[] | {name, conclusion, head_sha}'` and name which CI job matches which repo check; write "by CI" in Verification Results; it is a signal, never evidence for a finding, and never covers a `security` or `data-loss` gap); a harness denial counts as could-not-run. Logic testing (E4b) that could not run on an untrusted target is not an INCOMPLETE trigger by itself; it is a note in Verification Results. Not covered triggers INCOMPLETE only for high-risk groups (auth, data access, infrastructure, migrations, public APIs, security); a low-risk group left unread never triggers it, on any target; it is listed under Not covered in the Summary.

## Re-check

When re-checking, add a section **Previously raised findings** (each: title, severity, `path:line`, Resolved / Still open / Not re-verified, one line on what you ran) before **Findings**, and call the second **New findings**.
