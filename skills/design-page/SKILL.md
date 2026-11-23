---
name: design-page
description: "Write or restructure a HIGH-LEVEL SYSTEM or ARCHITECTURE DESIGN page (what a system is, why it exists, its components and how they fit, key decisions, failure behavior) using a fixed section template, then publish it to Confluence with the confluence skill. Use ONLY for system or architecture design pages. Do NOT use for runbooks, how-tos, meeting notes, status or release notes, API or reference docs, post-mortems, specs for a single feature, or any other kind of page. Usage: /design-page <topic or existing page url>"
metadata:
  version: "1.0.0"
  category: documentation
  tags: ["confluence", "design", "architecture", "documentation"]
compatibility:
  universal: true
---

# Design page

A template for one kind of page: the high-level design of a system. It makes such pages short, consistent and readable by someone who has never seen the system. Publishing and editing go through the `confluence` skill (`~/.claude/skills/confluence/SKILL.md`); this skill decides what to write and how it is laid out.

## When to use it (and when not)

Use it when the page's job is to explain **what a system is, why it exists, its parts and how they work together**: a new system design, a design overview, an architecture page, or a rewrite of one.

Do not use it, and do not suggest it, for any other page: runbooks, how-to guides, onboarding, meeting notes, project plans or status, release notes, API or CLI reference, post-mortems, decision records, a design of one small feature inside an existing system. If the purpose is unclear, ask one question ("is this the high-level design of a system?") before applying the template. For other page types, use the `confluence` skill directly.

## Workflow

1. **Gather facts, do not invent them.** Sources: the user, the repo (README, CLAUDE.md, code), linked tickets (`/jira`), existing Confluence pages (`confluence` skill, read-only). For an existing page to restructure, read it in storage format first. Every statement in the page must trace to a source; list what is missing as questions instead of guessing. Quality goals need numbers from the user or the owners; without them they go in open questions. Anything not yet decided is marked as an open question, never written as fact.
2. **Size it.** Decide with the user whether this is a small system (core sections only) or a large or critical one (add the sections that apply: quality goals, key flows, data, security and cross-cutting concerns, deployment, decisions and alternatives). Then fit `references/template.md`: keep its section order, include a non-core section only when it has real content, never pad. The template is a checklist of what readers may need, not a form.
3. **Draft in plain text first** and show the outline plus the draft to the user. Ask about gaps. Keep it short: a reader should grasp the system from the Summary, and every other section earns its place.
4. **Render to Confluence storage format** using `~/.claude/skills/confluence/references/storage-snippets.md` (panels, table of contents, status lozenges, code blocks, tables). Use the exact snippets; do not invent macros. Check that the XML is well formed before sending.
5. **Publish only through the `confluence` skill's create or edit flow**, with its diff, confirmation, backup and verification. For a rewrite of an existing page, show a clear before/after of the structure and keep any macros, images and links you are not changing.
6. **Diagrams:** the confluence skill cannot upload images. Describe the diagram in a short text or ASCII sketch, insert the image placeholder from the snippets, and tell the user which diagram to attach at that spot.

## Rules

- Plain, concise, accurate; written for a new reader; define terms once. No filler, no implementation trivia (leave that to the repo README, and link to it), no claims you have not checked against the code or the user.
- Regular hyphens only, never em dashes.
- State decisions with their reason, name the alternatives rejected, and state non-goals explicitly. Describe failure behavior as design, not as an afterthought.
- Set the owner, status and review date; they are what keeps the page trustworthy. Link to the source of truth for anything that drifts.
- Never change an existing page's meaning while restructuring it: when unsure whether a statement is still true, ask.
