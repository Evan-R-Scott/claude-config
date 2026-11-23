# High-level design page: template

Structure follows what readers of production architecture documentation need, combining arc42 (context, building blocks, runtime view, cross-cutting concepts, decisions, risks), the C4 model (context and container diagrams), and the design-doc convention (goals and non-goals, alternatives considered). The page type is Diataxis "explanation": it explains what the system is and why it is built this way. It does not teach (tutorial), give task steps (use `doc-runbook`) or list every detail (reference, the README).

This is a checklist of what a reader may need, not a form. Keep the section order below. **Core** sections are on every page. The others are included only when they have something real to say for this system; never fill a section to complete the template, and say "not applicable" only when a reader would otherwise wonder. Small system: core sections only. Large or critical system (many components, external users, data, security or availability stakes): add what applies.

## Section order (the only order; core sections marked *)

1. Summary * 2. Page metadata * 3. Table of contents (when longer than a screen) 4. Why it exists * 5. Capabilities * 6. Quality goals 7. Non-goals * 8. Constraints and assumptions 9. System overview * 10. Components * 11. Key flows 12. Data 13. Domain section(s) 14. Output 15. Deployment and operations 16. Reliability and failure behavior * 17. Cross-cutting concerns 18. Decisions and alternatives 19. Risks, open questions and limitations * 20. Using it from tools 21. Glossary 22. Related * (always last). The positions named in the details below agree with this list; when in doubt this list wins.

## Core sections

- **Summary** (info panel, first thing on the page). What the system does, for whom, and its key contribution, in 2-3 sentences. No history or internals. A reader who stops here still knows what the system is.

- **Page metadata** (one line): Status (Draft, Approved or Superseded), Owner (team or role), Last reviewed (date), Audience.

- **Table of contents** (levels 2-3), for pages longer than a screen.

- **Why it exists** (h2). The problem today, who feels it, what it costs, and why this system answers it, in one paragraph. Cost of the status quo, not a feature list.

- **Capabilities** (h2). Two-column table Capability | Description: what users can do, from the user's side. Key external references (config, manifests, shared locations, dashboards) in one line under the table.

- **Non-goals** (h2). Things a reader might reasonably expect that the system deliberately does not do, each with one sentence on the boundary or who owns it instead. Not negated goals such as "must not crash".

- **System overview** (h2). Context first: who and what the system talks to (users, upstream and downstream systems) and what is inside and outside its boundary, then one diagram of the main parts and the flow (C4 context and container levels; one diagram each at most) with a caption of how to read it.

- **Components** (h2). One sentence on how a request or run moves through the parts, then a numbered list of the parts in order, then one h3 per part: its responsibility, what it does in order, what it refuses or hands off, its interfaces. Record each local non-obvious choice as a **Design decision** note panel: the decision, the alternative it avoids, the consequence accepted, how that consequence is handled.

- **Reliability and failure behavior** (h2). Bullets, each a bold lead plus one sentence: partial results, cleanup on error or abort, what is never cancelled or released, what is never silent, what is safe to delete, and what happens when each dependency is down.

- **Risks, open questions and limitations** (h2). Known risks with their mitigation, questions not yet decided with who decides, accepted limitations and technical debt. Nothing undecided is written as fact elsewhere on the page.

- **Related** (h2, last). Links to the repository README (implementation detail), runbooks, ADRs, dashboards, tickets.

## Add when they apply

- **Quality goals** (after Capabilities): a table Attribute | Target | How the design meets it, with measurable targets (availability, latency, throughput, capacity, freshness, cost). Without a number it is a wish; ask for it or list it as an open question.
- **Constraints and assumptions** (before System overview): technical, organizational or legal limits that shaped the design, and what the design assumes about its environment.
- **Key flows** (after Components): the runtime view. One to three numbered scenarios (the main path, and at least one failure or edge path), each as a short step list or a sequence diagram naming the parts involved.
- **Data** (after Key flows): what data is stored, where, its owner, retention, and how it moves; schemas stay in the repo.
- **Domain section(s)** (h2, one per core mechanism the system is judged on, such as how results are decided or how scheduling works): rules as a decision table (status lozenges for outcomes), prose for the reasoning, a **warning panel** for the one edge case a reader must not miss.
- **Output** (h2): what the system produces for users (report, API response, notification), in the order the reader sees it.
- **Cross-cutting concerns** (after Reliability): security and access (who may do what, how authenticated and authorized, secrets, sensitive data), scalability and capacity limits, observability (logs, metrics, alerts, where to look), configuration, and any compliance requirement. State plainly when the design deliberately provides none (for example, "relies on network access control, adds no authentication").
- **Deployment and operations** (before Reliability): where it runs, how it is deployed and configured, who operates it, link to the runbook.
- **Decisions and alternatives** (before Risks): for the few decisions that shaped the whole system, a table Decision | Alternatives considered | Why this one | Consequence. Link the team's ADRs when they exist instead of copying them.
- **Using it from tools** (h2): only when there is a supported integration (CLI, agent, API client): install, one usage example, optional tuning.
- **Glossary** (before Related): terms and acronyms used with a specific meaning.

## Style

- Lead each bullet with a bold noun or verb, then one sentence; no bullet longer than three sentences.
- Decisions, warnings and the one edge case readers must not miss live in panels, so they are found by scanning.
- Name things the way the system and its users name them; define each acronym once.
- Facts that drift (hostnames, paths, counts, schedules, versions) are stated once in the section that owns them; elsewhere refer to it. Prefer a link to the source of truth over copying it.
- Leave out: history and changelog, step-by-step operation (runbook), code and config detail (README), anything restating the code.
- Keep it maintainable: a page nobody updates is worse than a short one. Set the owner and review date, and keep volatile detail out.
