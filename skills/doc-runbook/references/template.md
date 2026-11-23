# Runbook / how-to page: template

Structure follows operations practice (one shared template with consistent metadata, ordered steps, verification, recovery, escalation, and a test and review record, as in the AWS Well-Architected runbook guidance and incident-response runbooks) and the Diataxis "how-to guide" type: action-focused, for a reader who already knows what they want to achieve. It does not teach concepts (link to the design page) and does not mix several tasks. One task or one alert per page.

Choose the type first, because it changes sections 5 to 7:

- **Procedure** (use a tool, perform a routine or planned task): steps run in a fixed order.
- **Alert response** (an alert fired, something is failing): triage first, then mitigate, then fix; the reader is under pressure and may be paged at night.

Order is fixed. Sections marked (optional) are dropped when empty. Short sections; numbered lists and tables over prose.

## Sections

1. **Summary** (info panel, first thing on the page). What the page lets the reader do and when to use it, in 1-2 sentences. Alert response: the alert name or symptom that sends the reader here, and the impact.

2. **Page metadata** (one line): Type (Procedure or Alert response), Owner (team or role), Last tested (date and how: run end to end, or reviewed only), Review cadence, Applies to (system, environment, version), Time needed or severity.

3. **Table of contents** (levels 2-3), for pages longer than a screen.

4. **Purpose and context** (h2, short). Why this procedure exists, what it achieves, and where it fits in the wider operation (what runs before or after). Link to the design page for background; do not explain the system here. Say if it is **safe to repeat** (idempotent) and whether it is automated in part (link the script or pipeline).

5. **Before you start** (h2). Prerequisites as a checklist: access and permissions, tools and versions, information to have ready, who to tell before starting (for changes with impact). Say how to check each one when it is not obvious.

6. **Procedure** or **Triage and mitigation** (h2). The core.
   - *Procedure:* numbered steps, one action each. Per step: the action in bold, a code block with the exact command if any, and "Expected:" with what the reader sees on success. Group long procedures under h3 phases (Prepare, Run, Verify). A warning panel immediately before every destructive or irreversible step, with its undo. Branches are explicit ("If X, go to Troubleshooting: X"), never buried in prose. For a tool how-to, treat installation as a prerequisite (link the tool's README for install and concepts; tutorials and tool onboarding belong there, not here), and write one procedure per common task, the first of which is the shortest useful one.
   - *Alert response:* first check impact and severity, then a short decision list of quick checks (check, command, what a bad result looks like, next step), then **mitigation first** (restore service: restart, fail over, roll back, scale) before root cause, with the exact commands and expected results. Who to notify and when (incident channel, stakeholders) is a step, not an afterthought.

7. **Verify it worked** (h2). Observable checks that prove the task is done or service is restored: a command and its expected output, a dashboard value, a message. Not "it should work".

8. **Troubleshooting** (h2). A table Symptom or error text | Likely cause | Fix. Use the exact error text readers will search for. Link a deeper page instead of explaining at length.

9. **Roll back** (optional, h2). How to undo the whole procedure and verify the undo. When undoing is not possible, say so here and in the warning panel.

10. **Escalation** (h2). When to stop and escalate (a stated time or condition), whom (roles and channels, not private contact details), and what to include (logs, ticket, times, what was already tried).

11. **Follow-up** (optional, h2). What to do after: ticket or post-incident review, cleanup, updating this page when a step was wrong or missing.

12. **Related** (optional, h2). Design page, source repository, dashboards, neighbouring runbooks.

## Style

- A reader should be able to do the task using only bold actions, code blocks and "Expected" lines.
- No background or history beyond Purpose and context; link out. No step that needs judgment without a stated criterion.
- State values that drift (hostnames, versions, limits) once; mark anything environment specific. Prefer a link to the source of truth over a copy.
- Leave out: unverified commands, secrets, advice for cases the owner has not seen.
- A runbook is only as good as its last test: record how it was tested, walk it through once with someone who has not used it, and fix the page where they hesitate.
