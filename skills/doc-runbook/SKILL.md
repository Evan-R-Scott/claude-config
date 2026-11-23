---
name: doc-runbook
description: "Write or restructure a RUNBOOK or HOW-TO document (runbook, playbook, SOP, on-call or alert response, how-do-I) from a fixed template, as a Confluence page or a Markdown file. ONLY for step-by-step, task-oriented docs. NOT for system or architecture design (doc-design), a README, onboarding or tutorial, meeting notes, plans, release notes, API or reference docs, post-mortems, or ADRs. Usage: /doc-runbook <task | existing doc path or url>"
metadata:
  version: "1.0.0"
  category: documentation
  tags: ["confluence", "runbook", "how-to", "documentation"]
compatibility:
  universal: true
---

# Runbook doc

A template for documents whose job is to get a reader through a task correctly: use a tool, run an operation, recover from a failure. The reader is often tired or in a hurry, so the page is scannable and every step is checkable. This skill decides what to write and how it is laid out; where it goes (Confluence page or Markdown file) and how it is rendered and published is in `~/.claude/skills/doc-render/SKILL.md`.

## When to use it (and when not)

Use it when the reader will **follow the page to do something**: "how to use X", "how to rotate Y", "what to do when alert Z fires", an on-call or deployment procedure, a setup procedure for one task (not an onboarding guide or tutorial).

Do not use it for pages that explain what a system is and why it is built that way (that is `doc-design`), or for a README, onboarding guide or tutorial, meeting notes, project plans or status, release notes, API or CLI reference, post-mortems, or ADRs and decision records. If the purpose is unclear, ask one question ("will someone follow this page step by step to do a task?") before applying the template.

## Workflow

1. **Gather facts, do not invent them.** Sources: the user, the repo (README, scripts, CI config), tickets (`/jira` when installed), existing pages (`confluence` skill, read-only), tool `--help` output. Every command and expected output in the page must come from a source (the repo, the tool's own `--help` or docs) or from running a safe, read-only command. A basic command of a widely known tool (for example `git push`) may be written when you label it standard usage, not repo-specific; any other command you have not seen is an open question. If existing docs already cover the procedure, link to them and write only what they lack. Missing or uncertain details become questions, not guesses.
2. **Pick the type and fit the template** in `references/template.md`: Procedure (steps in a fixed order) or Alert response (triage, mitigate, then fix; the template gives it its own layout: severity, quick checks, mitigation). Keep the page to one task or one alert. Keep section order, drop an optional section when it has nothing real to say; the template is a checklist, not a form.
3. **Draft in Markdown first** and show it to the user with the gaps listed. Ask who owns the page, who is escalated to, when to escalate, and whether the procedure is safe to repeat; if you cannot ask, follow `~/.claude/skills/doc-render/SKILL.md` section 0.
4. **Choose the destination and render it** by following `~/.claude/skills/doc-render/SKILL.md`: Confluence page or Markdown file, with its rendering rules, publishing flow and confirmation steps. For a rewrite of an existing doc, keep the macros, images and links you are not changing.
5. **Verify the commands against the destination:** for a Confluence page, commands and code blocks must survive rendering unchanged (compare them with the draft); a Markdown file written directly needs no such check.
6. **Say what was not verified.** Tell the user which steps were not run end to end and ask them (or the page's owner) to walk through the page once, ideally someone new to the task, before it is relied on; set "Last tested" only to what actually happened, and add a review cadence.

## Rules

- A threshold, time limit or severity scale with no source is labelled "(assumption)"; an error message you have not seen is described in words, never invented.
- Steps are imperative and numbered, one action each; every step that can fail states what the reader should see when it worked. Alert runbooks mitigate before they diagnose.
- Commands are copy-pasteable in code blocks, with placeholders in capitals for values the reader supplies. Never put a secret, token, internal password or personal address in a page: refer to where it is kept.
- Mark every destructive or irreversible step with a warning panel before it, and give the undo (or say there is none).
- Plain, concise, accurate; written for a reader who has not done this before. Regular hyphens only, never em dashes.
