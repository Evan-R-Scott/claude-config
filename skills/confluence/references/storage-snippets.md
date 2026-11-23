# Confluence storage-format snippets

Shared by `confluence` and the page-type skills (`doc-design`, `doc-runbook`). Exact XHTML for the elements their templates use. Escape `& < >` in text. Do not add `ac:local-id` or `ac:macro-id` attributes; Confluence adds them on save. Panels use `containerLevel` `panel_c1`.

## Summary panel (info) and table of contents

```xml
<ac:structured-macro ac:name="info"><ac:parameter ac:name="containerLevel">panel_c1</ac:parameter><ac:rich-text-body><p><strong>Summary</strong></p><p>TEXT</p></ac:rich-text-body></ac:structured-macro>
<ac:structured-macro ac:name="toc"><ac:parameter ac:name="maxLevel">3</ac:parameter></ac:structured-macro>
```

## Headings, lists, inline

```xml
<h2>Why it exists</h2><p>TEXT with <strong>bold</strong>, <code>code</code> and <a href="https://example.com">a link</a>.</p>
<ul><li><p><strong>Lead.</strong> One sentence.</p></li></ul>
<ol><li><p>First part.</p></li><li><p>Second part.</p></li></ol>
```

## Design decision (note) and edge case (warning) panels

```xml
<ac:structured-macro ac:name="note"><ac:parameter ac:name="containerLevel">panel_c1</ac:parameter><ac:rich-text-body><p><strong>Design decision: SHORT NAME</strong></p><p>DECISION, ALTERNATIVE AVOIDED, CONSEQUENCE ACCEPTED, HOW IT IS HANDLED.</p></ac:rich-text-body></ac:structured-macro>
<ac:structured-macro ac:name="warning"><ac:parameter ac:name="containerLevel">panel_c1</ac:parameter><ac:rich-text-body><p><strong>TITLE</strong></p><p>THE EDGE CASE AND WHAT HAPPENS.</p></ac:rich-text-body></ac:structured-macro>
```

## Tip and success panels (runbooks)

```xml
<ac:structured-macro ac:name="tip"><ac:parameter ac:name="containerLevel">panel_c1</ac:parameter><ac:rich-text-body><p><strong>TITLE</strong></p><p>TEXT</p></ac:rich-text-body></ac:structured-macro>
```

## Numbered procedure step with command and expected result

```xml
<ol><li><p><strong>Do the thing.</strong> One sentence on why.</p><ac:structured-macro ac:name="code"><ac:parameter ac:name="language">bash</ac:parameter><ac:plain-text-body><![CDATA[COMMAND]]></ac:plain-text-body></ac:structured-macro><p>Expected: WHAT YOU SEE WHEN IT WORKED.</p></li></ol>
```

## Table (header row, then rows) and status lozenge

```xml
<table><tbody><tr><th><p>Capability</p></th><th><p>Description</p></th></tr><tr><td><p>NAME</p></td><td><p>TEXT</p></td></tr></tbody></table>
<ac:structured-macro ac:name="status"><ac:parameter ac:name="colour">Red</ac:parameter><ac:parameter ac:name="title">New failure</ac:parameter></ac:structured-macro>
```

Status colours: `Red`, `Green`, `Yellow`, `Grey`, `Blue`. Put a lozenge inside a table cell's `<p>`.

## Code block

```xml
<ac:structured-macro ac:name="code"><ac:parameter ac:name="language">bash</ac:parameter><ac:plain-text-body><![CDATA[COMMAND]]></ac:plain-text-body></ac:structured-macro>
```

## Diagram placeholder (the user attaches the image)

```xml
<h2>System overview</h2><p><em>[Diagram to attach here: DESCRIBE WHAT IT SHOWS.]</em></p>
```

After the user uploads the image named `system-overview.png` to the page, it can replace the placeholder with:

```xml
<ac:image ac:align="left" ac:layout="align-start" ac:custom-width="true" ac:alt="System overview" ac:width="900"><ri:attachment ri:filename="system-overview.png" /></ac:image>
```
