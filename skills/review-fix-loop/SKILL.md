---
name: review-fix-loop
description: "Run a review, fix its findings, and re-review until the reviewer approves or only nits remain, keeping every round anchored to the original change and its purpose so the loop does not drift into unrelated issues. Use when asked to 'review and fix until approved', 'loop the review', or 'fix and re-review'. NOT for a single review (review) or for fixing without re-review. Usage: /review-fix-loop <the same target arguments as /review> [--max-rounds N]"
---

# Review-fix loop

Round 1 is a normal `/review`. Each later round fixes what the last report found, then re-reviews. The risk of a loop is
drift: by round 3 the reviewer is finding new things in code the change never touched, and the fixer is chasing them. This
skill prevents that with a fixed scope written down before round 1.

## 1. Write the scope anchor (before round 1, and never edit it)

Save it to a file in the scratchpad (`scope.md`) and put its text in every reviewer prompt. It holds:

- **Purpose:** one or two sentences: what the change is for, in the user's words.
- **Target:** the exact files, folders or diff under review (the same `/review` arguments every round).
- **In scope:** defects in that target that affect its purpose, plus gaps the purpose itself requires (for example "does the set
  of runbooks cover what a maintainer needs").
- **Out of scope:** everything else, stated as a rule: problems in files outside the target, pre-existing issues the change did
  not introduce or touch, style preferences, and improvements nobody asked for.

If the purpose is unclear, ask the user one question before round 1.

## 2. Each round

1. **Review.** Round 1: `/review` with the target. Later rounds: `/review --recheck <last report file>` with the same
   arguments, and add the anchor to the prompt with these rules for the reviewer:
   - Part A first: mark each earlier finding Resolved or Still open.
   - Part B (new findings) only when the problem is **in the target** and either **introduced by the last round's fixes** or
     **a defect that affects the purpose and was missed earlier**. Anything else goes under `Out of scope observations`, one
     line each, and does not count toward the verdict.
   - Say what changed since the last round and review that, not the whole target again from scratch.
2. **Triage** every finding yourself against the anchor, not just by severity:
   - **Fix:** in scope and a real defect (verify it against the code first; reviewers are sometimes wrong).
   - **Reject:** wrong, or contradicted by the code. Say why in one line; do not fix it.
   - **Defer:** real but out of scope. Collect it for the final message; do not fix it here.
3. **Fix** only the triaged findings, with the smallest change that resolves each, and fix the class of issue the finding names, not only the reported instance: check the fix against variations of the case (other names, other optional parts present or absent, another instance) so it does not just patch the example. No cleanup, no neighbouring edits, no new
   scope. If a fix needs a decision that is the user's (an owner, a threshold, a design choice), stop and ask.
4. **Check** what the repo's own checks cover (lint, tests, link check) before the next round.

## 3. Stop when

- the verdict is approved, **or** every remaining finding is a nit (LOW, style, wording); or
- `--max-rounds` is reached (default 4); or
- a round finds nothing new in scope, or the same finding comes back after a fix: stop and tell the user, do not loop
  again (a repeat means the finding is wrong, the fix is wrong, or it needs a decision).

Findings that only appear in round 3 or later, in code a fix did not touch, are drift: defer them. Never keep looping
because the reviewer is still finding things; the stop rule is about the target and its purpose, not about reaching zero.

## 4. Final message

Short: rounds run, what was fixed (one line each), what was rejected and why, and the **deferred list** (out-of-scope
findings, each with `path`), for other sessions. Do not fix deferred items unless the user says so. Do not commit or push
unless asked.
