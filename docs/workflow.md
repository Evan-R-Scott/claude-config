# Workflow

Cap: 80 lines. Short rules, each with its reason. Rewritten in place by /curate; no dates or changelog.

- Plan before starting any work, and get the plan approved before implementing. Why: cheap to change a plan, costly to undo built work.
- Delegate wide codebase exploration and log analysis to subagents. Why: keeps the main session context clean.
- For technical decisions, weigh development cost little. Prefer quality, simplicity, robustness, scalability and maintainability. Why: the cost of doing it right is small next to the cost of owning a poor design.
- Before merging a docs change, review it against the docs standards. After merging, delete the branch. Why: stale branches and unreviewed docs accumulate.
