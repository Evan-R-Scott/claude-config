---
name: plan
description: Read the task from recent session context, inspect the codebase, web-search docs and best practice, and produce a complete implementation plan with ordered steps, end-to-end testing/validation, and documentation change list. Usage: /plan
metadata:
  version: "1.0.0"
  category: planning
  tags: ["plan", "architecture", "implementation"]
compatibility:
  universal: true
---

# Implementation Planning

Senior engineer producing a complete, verified implementation plan. Take the task from session context, understand the codebase, research best practices, and write a plan specific enough for anyone on the team to execute correctly.

Design principles: **correctness** (handles edge cases and failure paths), **simplicity** (fewest moving parts that satisfy the requirements), **scalability** (handles growth without structural rework).

The plan must always include: implementation steps, testing/validation, and documentation changes.

**Standing permissions (pre-authorized, no confirmation needed):** Reading any file. Web searches. These match the global standing permissions and require no user prompt.

**Write restriction:** Read-only. Do not create, modify, or delete any file or run any mutating command. The one exception is the PR branch checkout done by `pr-info` in Mode A (it refuses on a dirty tree). Output is the plan document and questions to the user only.

---

## Step 1: Extract task and detect mode

Read the last several messages. Determine mode first - it changes scope and framing.

### Mode A: PR fix planning

Signals: PR URL/number/title in session, reviewer comments or `CHANGES_REQUESTED` present, user says "plan the fixes for this PR."

**1a: Load the PR.** If the session does not already hold it, follow the `pr-info` skill (`~/.claude/skills/pr-info/SKILL.md`): it resolves any PR URL or `owner/repo#N`, fetches metadata, CI and review threads, and checks out the PR branch when the current directory is that repo's clone. Hold: title/number/URL, `headRefName`, `baseRefName`, description, every reviewer comment (file/line/hunk, resolved or not), `reviewDecision`.

**1b: Read the full diff.**
```bash
gh pr diff <url>
git log origin/<baseRefName>..HEAD --oneline --no-decorate   # only when on the PR branch
```

**1c: Read every changed file in full.** A/M/R: Read tool. D: `git show origin/<baseRefName>:<filepath>`. Read related files if a changed file calls into them and a reviewer comment is relevant.

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

---

### Mode B: Net-new task

Extract: what needs to be built/changed/fixed, why, which repos/services are in play, constraints (deadlines, compatibility, things that must not change).

---

### Both modes: clarification threshold

Most context is already in the session. Before asking anything, check whether Step 2 repo context or Step 3 web research would answer it. Only prompt if a gap would fork the plan into meaningfully different designs and can't be resolved from the codebase. Batch all questions into one AskUserQuestion call. If something is unknowable, note it as an open question in the plan rather than blocking.

---

## Step 2: Load repo context (silent)

Read `CLAUDE.md` at the repo root (follow any triggers relevant to the task), `CONTRIBUTING.md`, and relevant `docs/` pages. Read quality-config files (`pyproject.toml`, `.eslintrc`, `go.mod`, `Makefile`, `package.json`, etc.) to understand language, toolchain, and conventions. If the task spans multiple repos, read each repo's CLAUDE.md. Do not summarize to the user.

---

## Step 3: Read the codebase

For anything beyond a few files, delegate the sweep to an Explore subagent (breadth "medium") and keep only its conclusions in this session; read the few decisive files yourself. Read every file relevant to the task. Understand the current architecture, the patterns in use, what already exists that might be reused or extended, and what the task will touch or interact with. For net-new work: understand the system well enough to design something that fits. For PR fix work: already done in 1b-1c.

Do not skip this step, however it is done. A plan written without reading the code will miss interactions, duplicate existing logic, or design against the grain of the codebase.

---

## Step 4: Web search for documentation and best practice

Scale research to risk. Search for every decision that depends on an external API, library version, security pattern or practice you are not certain is current; skip it for purely internal changes the codebase already settles. Use official docs, not memory. APIs change, best practices evolve, and libraries deprecate.

**Search for every relevant component:**
- Language feature or API being used: confirm correct usage and current version
- Library or framework: official docs, changelog, deprecation notices
- Security patterns (auth, input validation, secret handling, access control): best practices for the stack in use
- Design patterns: confirm the approach matches current recommendations
- Any non-obvious approach: find authoritative guidance before committing to it

For each search: note source URL, key recommendation, whether it changes the design. If a search reveals the planned approach is deprecated or suboptimal, redesign that part and note the source.

---

## Step 5: Design the implementation

**5a: Architecture decisions.** For each significant choice: Decision, Rationale (grounded in Steps 2-4), Alternatives considered, correctness/simplicity/scalability tradeoffs.

Ask for every component:
- **Correctness:** Handles all error paths? Edge cases covered? Concurrent access safe?
- **Simplicity:** One thing per component? Existing utilities reusable? Adds maintainable surface area?
- **Scalability:** Works at larger input sizes or load without structural rework? Hard-coded values that should be parameters?

**5b: Compatibility check.** Cross-reference decisions against the codebase from Steps 2-3:
- Naming and patterns follow existing conventions?
- Dependencies or interfaces the new code must interoperate with?
- Existing tests that will need updating?
- Anything currently working that this change could break?

---

## Step 6: Write the plan

Implementation Steps, Testing and Validation and Documentation Changes are always required. Include every other section only when it adds information for this task (a one-file fix does not need a component diagram or scalability design). Vague steps are useless.

---

# Implementation Plan: `<task title>`

## Summary

2-4 sentences: what this implements, why, and what the end state looks like.

**Mode:** Net-new / PR fix | **Repos:** | **Language/stack:**

---

## PR Fix Context *(PR fix mode only)*

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

---

## Context and Current State

What the codebase currently does in the relevant area, what's missing, pre-existing issues the plan should be aware of.

---

## Architecture

### Design Decisions
Choice, rationale, alternatives, correctness/simplicity/scalability tradeoffs. Reference Step 4 sources.

### Component Diagram *(if non-trivial)*
ASCII diagram.

### Correctness Design
How the design handles: invalid inputs, partial failures, concurrent access, edge cases.

### Scalability Design
How it handles growth and what parameters control it.

---

## Prerequisites

- [ ] Dependencies to add (package names and versions)
- [ ] Config or environment variables to set
- [ ] Existing resources or systems that must be in a specific state
- [ ] Branch/PR targets per repo
- [ ] Approvals or coordination required

---

## Implementation Steps

Each step: atomic, reversible where possible, specific (exact file paths, function names, values), scoped (which repo and directory).

**PR fix mode:** Only Implement-verdict comments become steps. Each step references the comment #. Out-of-scope items go to follow-up, not here.

### Step N: `<title>`

**Repo:** | **File(s):** | **Addresses:** *(PR fix mode)* Comment #N (verdict) - reminder of request
**Purpose:** One sentence on what this does and why it's at this point in the order.

Exact description of what to change/create. Show relevant code snippets or pseudocode where the change is non-obvious. PR fix mode: what the current code does vs. what it does after the fix, grounded in the file content from 1c. "Implement with modification": explain why approach differs from reviewer's suggestion.

**Revert:** How to undo this step.

---

*(Repeat. Net-new: foundational pieces first, then dependent layers. PR fix: foundational issues before surface-level, logical sequence.)*

---

## Reviewer Comment Resolutions *(PR fix mode only)*

### Implemented
For each Implement/Implement-with-modification verdict:

**Comment #N** - `@reviewer` (`path:L42`) > quote
**Action:** What's being changed and which step covers it. For modification: what differs from reviewer's suggestion and why.

### Declined
For each Decline verdict:

**Comment #N** - `@reviewer` (`path:L42`) > quote
**Verdict:** Decline - already handled / not applicable / wrong tradeoff
**Reason:** Full evidence-backed explanation with specific source cited.

### Answered
For each question/discussion:

**Comment #N** - `@reviewer` (`path:L42`) > quote
**Answer:** Full researched answer. If it reveals a change is warranted, move to Implemented.

### Deferred
For each Defer verdict:

**Comment #N** - `@reviewer` (`path:L42`) > quote
**Why deferred:** Out-of-scope rationale and what follow-up should address it.

---

## Testing and Validation

Every check must be runnable by someone who didn't write the plan. Each produces a specific, observable outcome.

**Principles:** Test each layer before end-to-end. Test the unhappy path. Confirm edge cases. Confirm rollback works.

### Pre-implementation baseline
State to diff against after:
- Current test suite results
- Key behaviors or outputs to verify are preserved

### Post-implementation validation (per step)

**Validate Step N:** `<title>`

What to run and what specific output/behavior to expect. Not "should work" - a concrete observable outcome.

### End-to-end validation

**E2E 1: `<what>`** - Steps to exercise the full feature and observe correct behavior. Expected: concrete description.

**E2E 2: Failure/edge case** - Exercise the failure path or edge case. Expected: concrete error or fallback behavior.

**E2E 3: Regression** - Confirm existing behavior is preserved. Expected: same outputs as baseline.

### Rollback procedure
1. Specific revert step
2. Verify rollback by re-running baseline check

---

## Documentation Changes

### Files to create
| File | Location | What to document |
|---|---|---|

### Files to update
| File | Location | Section | Change needed |
|---|---|---|---|

### Files to delete
| File | Location | Why |
|---|---|---|

### CLAUDE.md updates
New operational area → trigger entry: which CLAUDE.md, `read this BEFORE <action>`, link to docs page. Inaccurate trigger → note update needed.

---

## Sources and References

- `<Decision>`: [title](url) - one-line summary of what it contributed

---

## Open Questions *(omit if none)*

- **Question:** | **Impact:** which steps affected | **Options:** viable choices and implications

---

## Step 7: Present and wait for approval

Present the plan in full. Ask whether to proceed or revise. Do not start implementation until the user explicitly approves. If the user requests changes: revise relevant sections, re-run affected web searches if the change materially alters the design, present updated plan.

---

## Rules

- **PR fix mode:** Read the full diff and every changed file before designing (1b-1c). Triage every comment before planning any step (1d). Every Decline needs specific evidence. Every implementation step must trace to an Implement verdict.
- Never skip Step 3 (read the codebase) - a plan written without reading the code will miss interactions or design against the grain.
- Step 4 (web search) is proportional, but never design from memory around an API, version or security practice that may have changed.
- No generic boilerplate. Every step, check, and doc change must be specific to this task.
- Cite every design decision that came from a documentation source.
- Do not start implementation - this skill produces a plan only.
- Prefer reading the codebase over asking the user. Batch all questions into one AskUserQuestion call.
