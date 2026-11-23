# Report template: pull request

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

(Use the Finding block from `report.md` for each finding.)

### Test Coverage Assessment

### Documentation Assessment (the table from `report.md`)

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

Checklist marks: see `report.md`.

### Verdict
For a MERGED or CLOSED pull request the verdicts read the same and the Summary says the review is retrospective.
- **APPROVE** - Ready to merge.
- **APPROVE WITH NON-BLOCKING FINDINGS** - No blockers; LOW/MEDIUM before or after merge.
- **REQUEST CHANGES** - One or more HIGH must be resolved.
- **DO NOT MERGE** - One or more CRITICAL. Significant rework required.
- **INCOMPLETE - NEEDS HUMAN CHECK** - the rules in `report.md` (State its reasons in the Verdict line, and never post it as an approval).
```
