---
name: doc-design
description: "Write or restructure a high-level SYSTEM or ARCHITECTURE DESIGN document (what a system is, why it exists, its parts, key decisions, failure behavior) from a fixed template, as a Confluence page or a Markdown file. ONLY for system or architecture design docs. NOT for runbooks or how-tos (doc-runbook), onboarding, meeting notes, project plans, release notes, API or reference docs, post-mortems, ADRs, or an RFC or design for a single feature. Usage: /doc-design <topic | existing doc path or url>"
metadata:
  version: "1.0.0"
  category: documentation
  tags: ["confluence", "design", "architecture", "documentation"]
compatibility:
  universal: true
---

# Design doc

A template for one kind of document: the high-level design of a system. It makes such docs short, consistent and readable by someone who has never seen the system. This skill decides what to write and how it is laid out; where it goes (Confluence page or Markdown file) and how it is rendered and published is in `~/.claude/skills/doc-render/SKILL.md`.

## When to use it (and when not)

Use it when the page's job is to explain **what a system is, why it exists, its parts and how they work together**: a new system design, a design overview, an architecture page, or a rewrite of one.

Do not use it, and do not suggest it, for any other document: runbooks, playbooks, how-to guides, onboarding, meeting notes, project plans or status, release notes, API or CLI reference, post-mortems, ADRs and decision records, an RFC or technical design for one feature or change (even if people call it a design doc). If the purpose is unclear, ask one question ("is this the high-level design of a system?") before applying the template. For other document types, use the `confluence` skill directly (or just write the file).

## Workflow

1. **Gather facts, do not invent them.** Sources: the user, the repo (README, CLAUDE.md, code), linked tickets (`/jira` when installed), existing Confluence pages (`confluence` skill, read-only). First check whether a doc about this system already exists (README, `docs/`, an existing page): if so, restructure it or write only what it lacks and link to it, never a second copy that will drift. For an existing Confluence page to restructure, read it in storage format first. Every statement in the page must trace to a source; list what is missing as questions instead of guessing. Quality goals need numbers from the user or the owners; without them they go in open questions. Anything not yet decided is marked as an open question, never written as fact.
2. **Size it.** Decide with the user (if you cannot ask, decide yourself and say so, see doc-render section 0) whether this is a small system (all of these hold: about five or fewer parts, one owner, no outside users who depend on its availability or behavior (a public CLI that anyone may run, with no uptime promise, does not count; library packages that other projects depend on do count), no availability, data-loss or security stakes: core sections only, plus Key flows when a failure path matters) or a large or critical one (any one of them fails: add the sections that apply: quality goals, key flows, data, trust boundaries, cross-cutting concerns, deployment, decisions and alternatives). Past about twelve parts (components or subsystems, not template sections), write a hub page plus one child page per subsystem instead of one long document. For a large or critical system read `references/large-systems.md` now; for a small one you do not need it. Say in one line under the metadata which size you chose and why. Then fit `references/template.md`: keep its section order, include a non-core section only when it has real content, never pad. The template is a checklist of what readers may need, not a form.
3. **Draft in Markdown first** and show the outline plus the draft to the user. Ask about gaps; if you cannot ask, follow `~/.claude/skills/doc-render/SKILL.md` section 0. Keep it short: a reader should grasp the system from the Summary, and every other section earns its place.
4. **Choose the destination and render it** by following `~/.claude/skills/doc-render/SKILL.md`: Confluence page or Markdown file, with its rendering rules, publishing flow and confirmation steps. For a rewrite of an existing doc, keep every macro, image and link you are not changing and show the user a clear before/after of the structure.
5. **Diagrams:** draw them as `mermaid` in Markdown. For Confluence the diagram cannot be uploaded by Claude: leave the labeled placeholder and tell the user which diagram to attach at that spot.

## Rules

- Plain, concise, accurate; written for a new reader; define terms once. No filler, no implementation trivia (leave that to the repo README, and link to it), no claims you have not checked against the code or the user.
- Regular hyphens only, never em dashes.
- State decisions with their reason, name the alternatives rejected, and state non-goals explicitly. Describe failure behavior as design, not as an afterthought.
- Set the owner, status and review state (a date only when someone actually reviewed it); they are what keeps the page trustworthy. Link to the source of truth for anything that drifts.
- Never change an existing page's meaning while restructuring it: when unsure whether a statement is still true, ask.
