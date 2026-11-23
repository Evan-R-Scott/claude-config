# PR fix mode

Read in full when the task is planning fixes for a pull request. It replaces the "Mode B" extraction in Step 1 and adds sections to the plan in Step 6. Steps 2 to 5 of `SKILL.md` apply unchanged.

## Reading the PR and triaging the comments (Step 1)

Signals: PR URL/number/title in session, reviewer comments or `CHANGES_REQUESTED` present, user says "plan the fixes for this PR." If the session also holds an unrelated new task, ask which one to plan.

**1a: Load the PR without moving the branch.** If the session does not already hold it, follow the `pr-info` skill (`~/.claude/skills/pr-info/SKILL.md`) with `--no-checkout`; if that file is missing, tell the user to run `./install.sh plan` from their claude-config clone and stop. Hold: title/number/URL, `head` (branch), `headSha` (the head commit, which pr-info reports), `base`, description, every reviewer comment (file/line/hunk, resolved or not), `reviewDecision`.

**1b: Read the full diff.** `gh pr diff <url>`.

**1c: Read every changed file in full, at the PR head.** If the current directory is a clone of the PR's repo and `git rev-parse HEAD` equals `headSha`, read the working tree. Otherwise read each file at the head with `gh api --hostname <host> repos/<owner>/<repo>/contents/<path>?ref=<headSha> -H "Accept: application/vnd.github.raw"`; the removed content of a deleted file is in the `gh pr diff` output, so it needs no separate read. Read related files if a changed file calls into them and a reviewer comment is relevant; read callers and conventions in the clone's current checkout, and say so when it is not the PR head.

**1d: Classify and evaluate every reviewer comment.**

Not every comment is a required fix. Evaluate each independently:

*Classify:* Required fix (correctness bug, security issue, broken behavior) / Requested change (design preference - needs evaluation) / Question / Discussion / Nitpick.

*Research each non-obvious comment:* Read the relevant code (already done in 1c - does the current implementation already address the concern?). Read team docs (repo CLAUDE.md, `docs/`). Run web searches if the comment is about best practice, an API, or a claim about how something works.

*Treat reviewer suggestions as a starting point, not a spec.* Before accepting a proposed fix, independently reason about it:
- Is the proposed approach actually the best option, or is there a simpler/safer/more correct alternative?
- Does it introduce new problems (regressions, edge cases, false positives, performance issues)?
- Are there interactions with adjacent code the reviewer didn't account for?
- Is the scope right - is this the right fix for the right problem?

Use "Implement with modification" liberally when the reviewer's concern is valid but their suggested approach is suboptimal. Explain *why* the modification is better, not just *what* it is. Never blindly implement a reviewer suggestion just because it was requested.

*Reach a verdict:*
- **Implement** - reviewer is correct and the proposed approach is the best option; describe what changes
- **Implement with modification** - concern is valid but suggested approach has a problem or a better alternative exists; describe the alternative and why it is superior
- **Decline - already handled** - current code already addresses the concern; cite exact file:line
- **Decline - not applicable** - concern doesn't apply to this context; cite evidence
- **Decline - wrong tradeoff** - suggested change would make things worse; explain tradeoff with source
- **Answer** - it's a question, not a change request; provide a researched answer
- **Defer** - concern is valid but out of scope; explain why and what follow-up should address it

Every Decline requires specific evidence. "This is fine as-is" is not a reason. Every "Implement with modification" must explain what is wrong with the reviewer's approach and why the alternative is better.

**1e: Scope constraint.** PR fix mode is scoped to the PR's existing changes. Each implementation step must trace to an Implement-verdict comment. Out-of-scope improvements go to follow-up items.

## Extra plan sections (Step 6)

### PR Fix Context (place it right after the Summary)

**PR:** #`<number>` - `<title>` (`<url>`) | **Branch:** `<head>` → `<base>` | **Decision:** `<reviewDecision>`

### Reviewer Comment Triage

| # | File | Line | Reviewer | Summary | Verdict |
|---|---|---|---|---|---|
| 1 | `path/to/file` | L42 | `@reviewer` | summary | Implement / Implement with modification / Decline - already handled / Decline - not applicable / Decline - wrong tradeoff / Answer / Defer |

For each comment expand:

**Comment #N** (`path/to/file:L42` - `@reviewer`)
> exact quote

**Type:** Required fix / Requested change / Question / Discussion / Nitpick
**Current implementation:** What the code at that location actually does (from 1c).
**Research:** What was checked - code, doc, web search - and what it showed.
**Verdict:** (from above)
**Reasoning:** Evidence-backed explanation. For Decline: cite exact source (doc URL, file:line). For Answer: the full answer. For Defer: why out of scope and what follow-up covers it.

### Implementation steps in this mode

Only Implement-verdict comments become steps. Each step references the comment #. Out-of-scope items go to follow-up, not here.

### Order of the per-comment records

Order the per-comment records above (and the triage table) by verdict: Implemented, then Declined, Answered, Deferred, so the author can answer each reviewer from the plan.
