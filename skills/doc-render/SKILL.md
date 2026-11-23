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
- Mark a claim you read in code or docs but did not run as "(inferred, not run)". Never write "Last reviewed" or "Last tested" with a date nobody earned: write "not yet reviewed" or "not run end to end".
- If no destination was given, or nobody can give the confirmation a publish needs (a Confluence create or edit, a whole-body replacement), write the Markdown draft to a local file at the default path, publish nothing, and say so in the final message.
- List the open questions and the unverified claims again in your final message, so the human sees them without opening the file.

## 1. Draft in Markdown for a new document

Write the draft as plain Markdown first. It is the working format the user reviews, and a new document converts to either destination without losing structure (an existing Confluence page with macros is the exception: see section 4). Use the mapping in section 3. The draft is restyled to the destination's convention (heading style, front matter, lint rules found in step 3.1) when it is rendered, so keep it plain.

## 2. Choose the destination

- The user said where (a Confluence URL or page id, "Confluence", a file or `docs/` path, "in the repo"): use that. An explicit link or path in the request wins over the repo's layout.
- Otherwise: a Confluence link or page in the conversation means Confluence; being inside a git repo with a `docs/` folder or a README-based doc convention means a Markdown file.
- Still unclear: ask once, "Confluence page or a Markdown file in this repo?" Do not publish to either without that answer.
- The same document in both places only when asked; the repo file is then the source and the Confluence page a copy, say so on the page.

## 3. Markdown file in a repository

1. **Find the convention before writing.** Outside a repository (a scratch location, or a path you were told) skip this: use the default name and heading style, write links to other files as plain text or absolute URLs, and say the relative links are unchecked. Otherwise read the repo's `CLAUDE.md`, `docs/README.md` or `CONTRIBUTING.md`, and look at 2-3 existing docs: folder, file naming, heading style, front matter, and whether a docs site generator (mkdocs, Docusaurus, Sphinx, Hugo) or a markdown linter config (`.markdownlint*`) exists. Follow what is there. With no convention: `docs/<kebab-case-title>.md`, one `#` title, no front matter, and a link from the nearest index (`docs/README.md` or the root README).
2. **Write the file with the Write tool** (new) or minimal Edit changes (existing), never regenerate an existing doc from a summary. Show the user the path and, for an existing doc, `git diff`. Do not commit or push unless asked. Run the repo's markdown lint or link check if one is configured.
3. **Rendering of the template elements:**

| Template element | Markdown |
|---|---|
| Summary panel | A `> [!NOTE]` alert whose first line is `**Summary**` (GitHub alert syntax; use a plain blockquote if the site does not support alerts) |
| Table of contents | Omit on GitHub (it shows one); a manual list of links for docs sites without one |
| Design decision / note panel | `> [!NOTE]` with a bold title line (GitHub advises few alerts per page, so keep to the ones that matter) |
| Warning panel | `> [!WARNING]` for an edge case readers must not miss; `> [!CAUTION]` before a destructive or irreversible step (both become the Confluence `warning` macro) |
| Tip panel | `> [!TIP]` |
| Status lozenge | Bold text: `**New failure**` (no colour dependence). When rendering to Confluence pick the colour by meaning: failure or blocked is Red, success or done is Green, warning, pending or in progress is Yellow, anything else is Grey |
| Tables, lists, headings, code | Standard Markdown; code fences with a language |
| Page metadata line | A line under the summary (for example `Status: Draft, Owner: team, Last reviewed: date` for a design doc or `Type: Procedure, Owner: team, Last tested: date (run end to end), Review: quarterly` for a runbook, separated by commas because a pipe splits a table cell), or front matter when the repo uses it |
| Diagram | A fenced `mermaid` block (renders on GitHub and most docs sites); fall back to a text diagram only if the destination cannot render it |
| Procedure step with command and result | Numbered list item with an indented code fence and an `Expected:` line |

4. **Links** between docs are relative paths that resolve from the file's folder; check each target exists. A literal `|` in a table cell splits it, even inside backticks: escape it as `\|` or reword. In a Confluence conversion, a relative link to a repository file becomes `<code>path</code>` or an absolute URL, never a dead link.

## 4. Confluence

**Restructuring an existing page that has macros, layouts or link cards:** do not round-trip it through Markdown (that drops them, which the `confluence` skill forbids). Use Markdown only for the outline shown to the user, and do the restructure on the storage body by moving whole section fragments; replacing the whole body needs its own named confirmation. A new page, or a page of plain text, can be rendered from the Markdown draft.

Convert the Markdown draft with the exact snippets in `~/.claude/skills/confluence/references/storage-snippets.md` (alert to macro: the `**Summary**` alert is the `info` panel, `[!NOTE]` is `note`, `[!WARNING]` and `[!CAUTION]` are `warning`, `[!TIP]` is `tip`; a mermaid block becomes the placeholder paragraph plus a code macro with no language holding the mermaid source (see the snippets file; do not repeat the section heading)), and publish only through the `confluence` skill's create or edit flow (diff, confirmation, backup, verification). The Markdown draft is what the user approved; the diff shown before writing is the storage-format change. Diagrams: the confluence skill cannot upload images, so leave the labeled placeholder plus the mermaid source (as in the snippets file) and tell the user what to attach.
