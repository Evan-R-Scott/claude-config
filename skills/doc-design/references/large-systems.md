# Sections for a large or critical system

Read when the system is large or critical (see `SKILL.md` step 2). Positions come from the section order in `template.md`; this file only describes the optional sections.

- **Quality goals**: a table Attribute | Target | How the design meets it, with measurable targets (availability, latency, throughput, capacity, freshness, cost). Only rows with a real, agreed target belong in it. If no targets exist, write one line of qualitative priorities (for example "safety over speed") and list the missing numbers under open questions; do not fill the table with proposed numbers. An invariant ("never writes to the user's tree") is a constraint, not a quality goal.
- **Data**: what data is stored, where, its owner, retention, and how it moves; schemas stay in the repo. A system with no persistent data says so in one line. A data pipeline puts lineage, schema evolution, freshness, backfill and replay here or in domain sections.
- **Domain section(s)** (h2, one per core mechanism the system is judged on, such as how results are decided or how scheduling works): rules as a decision table (status lozenges for outcomes), prose for the reasoning, a **warning panel** for the one edge case a reader must not miss.
- **Output** (h2): what the system produces for users (report, API response, notification), in the order the reader sees it.
- **Cross-cutting concerns**: security and access (who may do what, how authenticated and authorized, secrets, sensitive data), scalability and capacity limits, observability (logs, metrics, alerts, where to look), configuration, and any compliance requirement. State plainly when the design deliberately provides none (for example, "relies on network access control, adds no authentication").
- **Deployment and operations**: where it runs, how it is deployed and configured, who operates it, link to the runbook.
- **Trust boundaries and threats** (security-critical systems, or any system that handles untrusted input or code): a diagram or list of the trust boundaries (draw a boundary as a subgraph or cluster), what crosses each one, and a short threat list with the mitigation for each. Sensitive data and who may reach it belong here too.
- **Decisions and alternatives**: for the few decisions that shaped the whole system, a table Decision | Alternatives considered | Why this one | Consequence. A choice inside one component is a panel in Components instead, never both. If a rejected alternative was never recorded, write "alternative not recorded" instead of inventing one. Link the team's ADRs when they exist instead of copying them.
- **Using it from tools** (h2): only when there is a supported integration (CLI, agent, API client): install, one usage example, optional tuning.
- **Glossary**: terms and acronyms used with a specific meaning.

## Adapting to other kinds of systems

The section names assume a service. Translate them, do not force them: a "request" in Components is a run, event, job or build; "deployment" is where and how it is installed or released (a mobile app: platforms, release channels, offline behavior; an embedded system: hardware, resource budgets, real-time deadlines, safety and certification, which belong in Constraints and in domain sections); a "service catalogue" of many parts belongs on child pages. Parts that are not runtime units (files, templates, contracts between agents) are grouped under one h3 with their interfaces described as the contract they keep. When many parts have no documented design rationale, say so once.
