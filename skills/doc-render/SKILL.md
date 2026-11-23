---
name: doc-render
description: "Reference for the doc-* skills, not run directly: how to choose where a document goes (a Confluence page or a Markdown file in a repo) and how to render a doc template into either."
disable-model-invocation: true
---

# Doc render

Used by `doc-design`, `doc-runbook` and any other `doc-*` skill after the content is drafted. The content structure is the same for every destination; only the rendering and the publishing differ.

## 0. When you cannot ask the user (no interactive session, a subagent, a batch run)

Do not stop and do not guess silently. Draft the whole document and:

- Record every unanswered question as an assumption or open question inside the document: in "Risks, open questions and limitations" for a design doc, in "Open questions and assumptions" for a runbook. Never write an unknown as a fact. Owner and status: write "unassigned (to confirm)" and "Draft".
- Mark a claim you read in code or docs but did not run as "(inferred, not run)": tag the surprising or risky ones individually, and when nearly every claim is inferred say so once under the metadata instead of tagging every sentence. Never write "Last reviewed" or "Last tested" with a date nobody earned: write "not yet reviewed" or "not run end to end".
- If no destination was given, or nobody can give the confirmation a publish needs (a Confluence create or edit, a whole-body replacement), write the Markdown draft to a local file at the default path, publish nothing, and say so in the final message.
- List the open questions and the unverified claims again in your final message, so the human sees them without opening the file.

## 1. Draft in Markdown for a new document

Write the draft as plain Markdown first. It is the working format the user reviews, and a new document converts to either destination without losing structure (an existing Confluence page with macros is the exception: `references/confluence.md`). The draft is restyled to the destination's convention when it is rendered, so keep it plain.

## 2. Choose the destination

- The user said where (a Confluence URL or page id, "Confluence", a file or `docs/` path, "in the repo"): use that. An explicit link or path in the request wins over the repo's layout.
- Otherwise: a Confluence link or page in the conversation means Confluence; being inside a git repo with a `docs/` folder or a README-based doc convention means a Markdown file.
- Still unclear: ask once, "Confluence page or a Markdown file in this repo?" Do not publish to either without that answer.
- The same document in both places only when asked; the repo file is then the source and the Confluence page a copy, say so on the page.

## 3. Render it

Read only the file for the destination you chose, in full, then render and publish as it says:

- **Markdown file:** `~/.claude/skills/doc-render/references/markdown.md` (repo conventions, element mapping, links, diagrams as mermaid).
- **Confluence page:** `~/.claude/skills/doc-render/references/confluence.md` (storage-format snippets, alert-to-macro mapping, restructuring an existing page, publishing only through the `confluence` skill).
