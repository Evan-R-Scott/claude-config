# Rendering to Confluence

Read when the destination is a Confluence page (`SKILL.md` section 2).

## Confluence

**Restructuring an existing page that has macros, layouts or link cards:** do not round-trip it through Markdown (that drops them, which the `confluence` skill forbids). Use Markdown only for the outline shown to the user, and do the restructure on the storage body by moving whole section fragments; replacing the whole body needs its own named confirmation. A new page, or a page of plain text, can be rendered from the Markdown draft.

Convert the Markdown draft with the exact snippets in `~/.claude/skills/confluence/references/storage-snippets.md` (alert to macro: the `**Summary**` alert is the `info` panel, `[!NOTE]` is `note`, `[!WARNING]` and `[!CAUTION]` are `warning`, `[!TIP]` is `tip`; a mermaid block becomes the placeholder paragraph plus a code macro with no language holding the mermaid source (see the snippets file; do not repeat the section heading)), and publish only through the `confluence` skill's create or edit flow (diff, confirmation, backup, verification). The Markdown draft is what the user approved; the diff shown before writing is the storage-format change. Diagrams: the confluence skill cannot upload images, so leave the labeled placeholder plus the mermaid source (as in the snippets file) and tell the user what to attach.
