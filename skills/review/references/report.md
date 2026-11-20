# Report formats

Output the complete report in full as your final message: every section, every finding, every checklist item. Never summarize, condense or omit a part (a section with nothing to say is one line; LOW findings beyond the 5 most important are given as a count). Severities: **[CRITICAL]** outage, breach or data loss, must fix. **[HIGH]** a real usage problem, should fix. **[MEDIUM]** meaningful risk or debt. **[LOW]** style or cleanup (a nit). Every finding has evidence of the kind its category needs (engine, Filter 3), with the command and result shown. There is no severity for guesses: what you could not verify goes under Not verified. A finding's Category is one of: Correctness, Security, Performance, Tests, Docs, Hygiene, Design. When there is nothing to review, the report is three lines (see the engine): the header, a line `Verdict: NO CHANGES`, and the `Report file:` line. A header is one of `## Local Review:`, `## PR Review:` or `## Review:`. Every report ends with the `Report file:` line the engine asks for.

## Local changes and files

For a **files** target replace the header with `## Review: <paths>`, drop the Commit Readiness Checklist, make the Change Set section a list of the files reviewed with their sizes (there is no diff, no diffstat and no untracked list), leave out `Working copy untouched` (say `Files untouched` instead), and use these verdicts: **SOUND**, **SOUND WITH NON-BLOCKING FINDINGS**, **FIX BEFORE USE**, **DO NOT USE**, **INCOMPLETE - NEEDS HUMAN CHECK**, with the same precedence as the other templates: DO NOT USE > FIX BEFORE USE > INCOMPLETE > the two SOUND verdicts.

```
## Local Review: `<repo name>` (`<git|svn>`)
`<root>` | **Branch/URL:** `<branch or svn URL>` | **Scope:** `<scope used>`

### Summary
2-4 sentences: inferred intent of the change and overall verdict. List **Not covered** groups here for large changes.

### Change Set
Added / Modified / Deleted / Renamed / Untracked lists, with diffstat. Note anything skipped (binaries, generated, oversized) and, for large change sets, which groups were covered in depth.

### Verification Results
- **Repo checks (E4a):** each command, pass/fail
- **Logic testing (E4b):** what was tested, inputs used, pass/fail results
- **Research (E6):** the sources searched, or `N/A` and the reason
- **Notes:** tools that were missing, checks that did not apply or could not start, isolation that was not available (these are not Not verified items)
- **Run directory:** `<RUN>` | **Trust:** trusted / untrusted (none of the target's code run) | **Base:** `<base used for the new-failure re-run, or none>`
- **Snapshot cleaned:** yes/no | **Working copy untouched:** yes/no
- **Not verified:** what you could not run or check, each with a risk tag (`security`, `data-loss`, `concurrency`, `compat`, `other`), the file:line you traced, and the exact test or condition that would settle it. No severity.

### Findings

**[SEVERITY] Category - Title**
`path/to/file.ext:line` or `path/to/file.ext:first-last` (repo-relative, never a scratch path; add `(base)` for a removed line)
> snippet

Evidence: the command and result (`(confirmed)`). Explanation: what is wrong or missing and why it matters; when the direction is obvious, end with a clause saying which way to fix it (no code), as part of the same sentence flow, not a separate labelled line.

### Test Coverage Assessment

### Documentation Assessment

Identify every doc file that needs to be created, updated, or deleted - whether or not the change already includes it. Missing items become findings. State what is missing, not the wording to add.

| Action | File | Repo | Section / detail |
|---|---|---|---|
| Create / Update / Delete | `docs/path/file.md` | repo-name | what needs to change and why |

### Commit Readiness Checklist
- Logic correct, edge cases handled
- No security vulnerabilities or secrets
- No performance regressions
- Error handling complete
- Tests cover the change
- Lint and tests pass
- No debug leftovers or accidental files
- Change is one coherent unit
- Logging/observability appropriate
- Config environment-agnostic
- Backward-compatible
- Safe to deploy and rollback
- Documentation updated
- Follows project conventions

Checklist marks never count toward INCOMPLETE; only the triggers in the Verdict section do. Mark each: **Verified** (with the command or tool output) / **Finding** (with a reference to it) / **Not verified** / **N/A** (with the reason, when the item does not apply). Reading alone is never Verified; never mark "looks good" without evidence.

### Verdict
- **READY TO COMMIT** - No blockers.
- **READY WITH NON-BLOCKING FINDINGS** - No blockers; LOW/MEDIUM before or after commit.
- **FIX BEFORE COMMIT** - One or more HIGH must be resolved.
- **DO NOT COMMIT** - One or more CRITICAL. Significant rework required.
- **INCOMPLETE - NEEDS HUMAN CHECK** - Use whenever the target was untrusted and it has code whose repo checks (E4a) could not run, a check the repo defines could not run (but see the exceptions below), a high-risk area is under Not covered, or a Not verified item is tagged `security` or `data-loss`. Order of precedence: DO NOT COMMIT > FIX BEFORE COMMIT > INCOMPLETE > the two READY verdicts. State INCOMPLETE's reasons in the Verdict line (also when a higher verdict outranks it, name any `security` or `data-loss` Not verified reasons there). An optional scanner the repo does not use being unavailable, or a check that does not apply (N/A), never triggers it. A check the repo itself defines (its lint, type check or tests) that could not run, for any reason including a missing tool, does. Exceptions: a change set with no executable code (comments, docs, config, CI pins) never triggers the "could not run" reasons; a repo check that CI ran and passed on exactly the reviewed head SHA counts as run (show it with `gh api --paginate repos/<owner>/<repo>/commits/<headRefOid>/check-runs --jq '.check_runs[] | {name, conclusion, head_sha}'` and name which CI job matches which repo check; write "by CI" in Verification Results; it is a signal, never evidence for a finding, and never covers a `security` or `data-loss` gap); a harness denial counts as could-not-run. Logic testing (E4b) that could not run on an untrusted target is not an INCOMPLETE trigger by itself; it is a note in Verification Results. Not covered triggers INCOMPLETE only for high-risk groups (auth, data access, infrastructure, migrations, public APIs, security); a low-risk group left unread never triggers it, on any target; it is listed under Not covered in the Summary.
```

## Pull request

```
## PR Review: #`<number>` - `<title>`
`<url>`

**Branch:** `<headRefName>` → `<baseRefName>` | **Author:** `<author.login>` | **State:** `<state>` | **Decision:** `<reviewDecision, or none>`

### Summary
2-4 sentences: what this change does and overall verdict. List **Not covered** groups here for large changes.

### Commits Reviewed
Head commit reviewed: `<headRefOid>`. Then the commits (from the collected diff).

### Changed Files
(Added / Modified / Deleted / Renamed)

### Verification Results
- **CI:** Pass / Fail / Pending / N/A
- **Run directory:** `<RUN>` (the only place a scratch path appears; finding locations are repo-relative)
- **Trust:** trusted / untrusted (none of the target's code run)
- **Repo checks (E4a):** each command, pass/fail, and whether a failure also exists on the base
- **Logic testing (E4b):** What tested, inputs used, pass/fail results; copy removed: yes/no
- **Research (E6):** the sources searched, or `N/A` and the reason
- **Notes:** tools that were missing, checks that did not apply or could not start, isolation that was not available (these are not Not verified items)
- **Not verified:** what you could not run or check, each with a risk tag (`security`, `data-loss`, `concurrency`, `compat`, `other`), the file:line you traced, and the exact test or condition that would settle it. No severity.

### Existing Reviewer Feedback
Summarize prior comments. If none: _No reviewer comments._

### Findings

**[SEVERITY] Category - Title**
`path/to/file.ext:line` or `path/to/file.ext:first-last` (repo-relative, never a scratch path; add `(base)` for a removed line)
> snippet

Evidence: the command and result (`(confirmed)`). Explanation: what is wrong or missing and why it matters; when the direction is obvious, end with a clause saying which way to fix it (no code), as part of the same sentence flow, not a separate labelled line.

### Test Coverage Assessment

### Documentation Assessment

Based on what this PR changes, identify every doc file that needs to be created, updated, or deleted - whether or not the PR already includes those changes. Missing items become findings. State what is missing, not the wording to add.

| Action | File | Repo | Section / detail |
|---|---|---|---|
| Create / Update / Delete | `docs/path/file.md` | repo-name | what needs to change and why |

Include CLAUDE.md or AGENTS.md trigger changes if the PR introduces a new operational area agents should know to look up.

### Production Readiness Checklist
- Logic correct, edge cases handled
- No security vulnerabilities
- No performance regressions
- Error handling complete
- Tests cover the change
- CI green
- Logging/observability appropriate
- Config environment-agnostic
- Backward-compatible
- Safe to deploy and rollback
- Documentation updated
- Follows team conventions

Checklist marks never count toward INCOMPLETE; only the triggers in the Verdict section do. Mark each: **Verified** (with the command or tool output) / **Finding** (with a reference to it) / **Not verified** / **N/A** (with the reason, when the item does not apply). Reading alone is never Verified; never mark "looks good" without evidence.

### Verdict
For a MERGED or CLOSED pull request the verdicts read the same and the Summary says the review is retrospective.
- **APPROVE** - Ready to merge.
- **APPROVE WITH NON-BLOCKING FINDINGS** - No blockers; LOW/MEDIUM before or after merge.
- **REQUEST CHANGES** - One or more HIGH must be resolved.
- **DO NOT MERGE** - One or more CRITICAL. Significant rework required.
- **INCOMPLETE - NEEDS HUMAN CHECK** - Use whenever the target was untrusted and it has code whose repo checks (E4a) could not run, a check the repo defines could not run (but see the exceptions below), a high-risk area is under Not covered, or a Not verified item is tagged `security` or `data-loss`. Order of precedence: DO NOT MERGE > REQUEST CHANGES > INCOMPLETE > the two APPROVE verdicts. State INCOMPLETE's reasons in the Verdict line (also when a higher verdict outranks it, name any `security` or `data-loss` Not verified reasons there), and never post it as an approval. An optional scanner the repo does not use being unavailable, or a check that does not apply (N/A), never triggers it. A check the repo itself defines (its lint, type check or tests) that could not run, for any reason including a missing tool, does. Exceptions: a change set with no executable code (comments, docs, config, CI pins) never triggers the "could not run" reasons; a repo check that CI ran and passed on exactly the reviewed head SHA counts as run (show it with `gh api --paginate repos/<owner>/<repo>/commits/<headRefOid>/check-runs --jq '.check_runs[] | {name, conclusion, head_sha}'` and name which CI job matches which repo check; write "by CI" in Verification Results; it is a signal, never evidence for a finding, and never covers a `security` or `data-loss` gap); a harness denial counts as could-not-run. Logic testing (E4b) that could not run on an untrusted target is not an INCOMPLETE trigger by itself; it is a note in Verification Results. Not covered triggers INCOMPLETE only for high-risk groups (auth, data access, infrastructure, migrations, public APIs, security); a low-risk group left unread never triggers it, on any target; it is listed under Not covered in the Summary.
```

When re-checking, add a section **Previously raised findings** (each: title, severity, `path:line`, Resolved / Still open / Not re-verified, one line on what you ran) before **Findings**, and call the second **New findings**.
