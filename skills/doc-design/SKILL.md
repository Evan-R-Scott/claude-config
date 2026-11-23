---
name: doc-design
description: "Write or restructure a HIGH-LEVEL SYSTEM or ARCHITECTURE DESIGN document (what a system is, why it exists, its components and how they fit, key decisions, failure behavior) with a fixed section template, as a Confluence page or a Markdown file in a repo. Use ONLY for system or architecture design docs (an architecture or system overview, what a system is and how its parts fit). Do NOT use for runbooks, playbooks or how-tos (doc-runbook), onboarding guides, meeting notes, project plans or status, release notes, API or reference docs, post-mortems, ADRs or decision records, an RFC or technical design for one feature or change, or any other kind of document. Usage: /doc-design <topic | existing doc path or url>"
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

1. **Gather facts, do not invent them.** Sources: the user, the repo (README, CLAUDE.md, code), linked tickets (`/jira` when installed), existing Confluence pages (`confluence` skill, read-only). For an existing page to restructure, read it in storage format first. Every statement in the page must trace to a source; list what is missing as questions instead of guessing. Quality goals need numbers from the user or the owners; without them they go in open questions. Anything not yet decided is marked as an open question, never written as fact.
2. **Size it.** Decide with the user whether this is a small system (core sections only) or a large or critical one (add the sections that apply: quality goals, key flows, data, security and cross-cutting concerns, deployment, decisions and alternatives). Then fit `references/template.md`: keep its section order, include a non-core section only when it has real content, never pad. The template is a checklist of what readers may need, not a form.
3. **Draft in Markdown first** and show the outline plus the draft to the user. Ask about gaps. Keep it short: a reader should grasp the system from the Summary, and every other section earns its place.
4. **Choose the destination and render it** by following `~/.claude/skills/doc-render/SKILL.md`: Confluence page or Markdown file, with its rendering rules, publishing flow and confirmation steps. For a rewrite of an existing doc, keep every macro, image and link you are not changing and show the user a clear before/after of the structure.
5. **Diagrams:** draw them as `mermaid` in Markdown. For Confluence the diagram cannot be uploaded by Claude: leave the labeled placeholder and tell the user which diagram to attach at that spot.

## Rules

- Plain, concise, accurate; written for a new reader; define terms once. No filler, no implementation trivia (leave that to the repo README, and link to it), no claims you have not checked against the code or the user.
- Regular hyphens only, never em dashes.
- State decisions with their reason, name the alternatives rejected, and state non-goals explicitly. Describe failure behavior as design, not as an afterthought.
- Set the owner, status and review date; they are what keeps the page trustworthy. Link to the source of truth for anything that drifts.
- Never change an existing page's meaning while restructuring it: when unsure whether a statement is still true, ask.
