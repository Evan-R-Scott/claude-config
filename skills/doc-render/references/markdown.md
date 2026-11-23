# Rendering to a Markdown file

Read when the destination is a Markdown file (`SKILL.md` section 2).

## Markdown file in a repository

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
