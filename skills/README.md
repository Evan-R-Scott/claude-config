# User-level skills: general, never company or project specific

Everything in this folder is a general skill meant to work across projects and companies. Read this before adding to or editing any skill here.

- Do not put company names, product or project names, internal hosts, URLs, tools, repository or file paths, ticket formats, domain terms (the vocabulary of one team's hardware or stack) or examples taken from one project into these skills. Write the rule in neutral terms (for example "a service", "an environment", "a structured field") and, if an example helps, make it generic or hypothetical.
- Where a skill needs project context it must get it from the project at run time (its CLAUDE.md, docs, code), not from the skill text.
- Company-specific or project-specific skills are a different thing and are welcome to carry company context and detail. They belong in a plugin or in the project's own `.claude/skills/`, not here. A skill that cannot be made neutral should be moved there, not kept here.
- Before saving an edit, scan the text you added for names, paths and terms that only make sense in one project, and rewrite them.

## Naming tells the two kinds apart

- A skill with a plain name (`review`, `plan`, ...) is general and follows the rules above.
- A company-specific user-level skill is named `<company>-<skill-name>` (one short company slug, the same for all of that company's skills) and may carry that company's context and detail. A project-specific skill is `<company>-<project>-<skill-name>`, or lives in the project's own `.claude/skills/`.
- When adding a skill, decide which kind it is first and name it accordingly. Never add a prefixed skill's content to a plainly named one, and rename or move a skill whose name and content disagree.
