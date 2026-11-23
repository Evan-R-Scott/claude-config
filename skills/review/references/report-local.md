# Report template: local changes and files

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

(Findings: the Finding block from `report.md`.)

### Test Coverage Assessment

### Documentation Assessment

### Commit Readiness Checklist
(For a change of about 20 changed lines or fewer write it grouped by mark, as `report.md` says, not as a 12-item list.)
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

Checklist marks: see `report.md`.

### Verdict
- **READY TO COMMIT** - No blockers.
- **READY WITH NON-BLOCKING FINDINGS** - No blockers; LOW/MEDIUM before or after commit.
- **FIX BEFORE COMMIT** - One or more HIGH must be resolved.
- **DO NOT COMMIT** - One or more CRITICAL. Significant rework required.
- **INCOMPLETE - NEEDS HUMAN CHECK** - the rules in `report.md` (State its reasons in the Verdict line).
```
