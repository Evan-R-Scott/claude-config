# Re-check (read only when you were given a previous report)

This is the re-check procedure of the engine. It adds a verification pass before the normal review and changes how the report's findings are laid out (see also the Re-check block in `report.md`).

The caller gives you the path of an earlier report, or for a pull request the comments of the current `gh` user. Read it, then:

**Part A, prior findings:** for each earlier finding, read the current code, locate the exact lines, re-run the original reproduction in the E5 copy, and mark it **Resolved** (the reproduction no longer fails), **Still open** or **Not re-verified** (you cannot run the reproduction now: untrusted target, no tools, trust changed) with one line saying what you ran. Each entry keeps the finding's severity, `path:line` and evidence, and counts toward the verdict. Explicitly re-attempt the earlier round's Not verified items. If a prior HIGH or CRITICAL was "fixed" but the fix is wrong or incomplete, say so and escalate.

Match each prior finding by file and the quoted snippet, not by line number (code moves). If the previous report was for a different target than this one, say so and treat each finding as Still open unless you can find that code by content.

**Part B, full independent review:** then do a full independent review of the current state: re-read every changed file, re-run E4 and E7, re-apply E8. Authors introduce new bugs while fixing old ones, so a re-check is as thorough as the first review. The report lists "Previously raised findings" separately from "New findings" (which does not repeat the Still-open ones). The goal of the loop is a report with no CRITICAL, HIGH or MEDIUM findings; say plainly when only nits remain.
