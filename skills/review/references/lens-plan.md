# Lens: plans, designs, specs and proposals

Judge whether following this would produce the intended result, safely.

- **Goal and scope:** is the goal stated, measurable and actually what is needed? What is explicitly out of scope? Does the plan solve the stated problem, or a neighboring one?
- **Assumptions:** list each one, and check the checkable ones against the code, the system or the docs. An unverified assumption that the plan depends on is a finding.
- **Completeness:** are all steps, owners, inputs and outputs present? What happens at each failure? Migration, rollout, rollback, monitoring, and the docs and tests that must change.
- **Ordering and dependencies:** does any step need something a later step creates? What can be done independently, and what must not be?
- **Alternatives:** was a simpler option considered? Is there a cheaper way to get most of the value? Is anything over-built for the need?
- **Risk:** what is the worst realistic outcome, how would it be noticed, and how is it undone? Security, data loss, outages, cost.
- **Evidence:** claims about performance, cost, compatibility or user need should have a source or a measurement. Flag the ones that do not.
- **Decisions and open questions:** are open questions listed with who decides? Is the recommendation clear?
- **Generality:** apply `lens-general.md`: is each rule derived from a contract or principle rather than a few observed samples, is product-specific data kept out of logic, and do the planned tests vary the case or only repeat the examples?
