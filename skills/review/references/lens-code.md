# Lens: source code, scripts and tests

Work through every item that applies, and look for what the author did not think of.

### Correctness
- Logic does what was intended? Off-by-one, nil/null dereferences, type errors?
- Edge cases: empty, zero, large inputs, concurrent access?
- Error returns checked everywhere? Silent regressions? Unreachable branches?
- Leftover debugging: stray prints, `TODO`/`FIXME` added, disabled tests, hardcoded local paths, committed scratch files?

### Security
- Input validated and sanitized? Injection possible (SQL, shell, template, path traversal)?
- Secrets/tokens/keys hardcoded, logged, or sitting in untracked files about to be added?
- Auth checks present? New dependencies well-maintained and not known-vulnerable?
- Sensitive data in errors/logs/responses? Safe file path construction?

### Performance
- N+1 queries, unnecessary nested loops, repeated expensive computations?
- Large datasets fully loaded when streaming works? Unbounded queries, missing pagination or indexes?
- Goroutines/threads/async without a cleanup path?

### Code Quality
- Follows codebase conventions? Names clear and consistent?
- Duplicated logic that should be shared? Functions doing too many things?
- Magic numbers/strings? Commented-out code? Misleading comments?

### Optimizations
- Simpler/more idiomatic way to express the logic? Stdlib replaces hand-rolled logic?
- Unnecessary intermediates, allocations, round-trips? Same computation repeated?
- Heavy abstraction where lightweight would do?

### Error Handling
- Errors propagated, not swallowed? Messages actionable?
- Retry logic for transient failures? Panics used correctly?

### Test Coverage
- Tests for new/changed logic? Cover happy path AND failure/edge cases?
- Tests test behavior, not implementation? No weakened or deleted tests to make things pass?

### Production Readiness
- Logging at right levels? Observability on critical paths?
- Config values hardcoded that should be env-specific?
- Behaves correctly at scale? Safe rollback path?
- DB migrations backward-compatible with rolling deploy? API contracts backward-compatible?
- Requires a specific workflow or manual step to take effect?

### Architecture
- Fits existing architecture or works around it?
- Abstraction level correct? Circular dependencies or tight coupling introduced?
- Change in the right layer?
