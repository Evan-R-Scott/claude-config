# Lens: source code, scripts and tests

Work through every item that applies, and look for what the author did not think of.

### Correctness
- Logic does what was intended? Off-by-one, nil/null dereferences, type errors?
- Edge cases: empty, zero, large inputs, integer overflow, time zones and DST, unicode and encoding?
- Concurrency and resources: shared state and locks, check-then-act races (TOCTOU), files, connections and goroutines/threads released on every path including errors?
- Retried or repeated operations idempotent (a retry, a re-run, a duplicate message does no harm)?
- Error returns checked everywhere? Silent regressions? Unreachable branches?
- Leftover debugging: stray prints, `TODO`/`FIXME` added, disabled tests, hardcoded local paths, committed scratch files?

### Security
- Input validated and sanitized? Injection possible (SQL, shell, template, path traversal)?
- Secrets/tokens/keys hardcoded, logged, or sitting in untracked files about to be added?
- Authentication AND authorization: is every access to a resource checked against its owner or tenant (IDOR), not only that the caller is logged in? New dependencies well-maintained and not known-vulnerable?
- Server-side requests to a user-influenced URL (SSRF), open redirects, CSRF on state-changing routes, unsafe deserialization, crypto misuse (weak or unsalted hashes, static IVs or keys, non-cryptographic random for tokens)?
- For a security-focused change, apply the `owasp-security` skill's checklist when it is installed.
- Sensitive data in errors/logs/responses? Safe file path construction?

### Performance
- N+1 queries, unnecessary nested loops, repeated expensive computations?
- Large datasets fully loaded when streaming works? Unbounded queries, missing pagination or indexes?
- Goroutines/threads/async without a cleanup path?

### Code Quality
- Follows codebase conventions? Names clear and consistent?
- Duplicated logic that should be shared? Functions doing too many things?
- Commented-out code? Misleading comments?
- Simpler or more idiomatic way to express the logic, stdlib in place of hand-rolled logic, abstraction heavier than the problem needs? (only when it is concretely demonstrable)

### Error Handling
- Errors propagated, not swallowed? Messages actionable?
- Panics used correctly? A transient failure handled where the code already retries elsewhere, not a new retry feature requested?

### Test Coverage
- Tests for new/changed logic? Cover happy path AND failure/edge cases?
- Tests test behavior, not implementation? No weakened or deleted tests to make things pass? Flaky by construction (wall-clock time, randomness, ordering, shared state)?

### Production Readiness
(Logging, config, rollback and docs are marked in the report checklist; look here for what the checklist does not cover.)
- DB migrations backward-compatible with rolling deploy? API contracts backward-compatible?
- Requires a specific workflow or manual step to take effect? Behaves correctly at scale?

### Architecture
- Fits existing architecture or works around it?
- Abstraction level correct? Circular dependencies or tight coupling introduced?
- Change in the right layer?
