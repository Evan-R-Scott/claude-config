# Communication

Cap: 80 lines. Short rules, each with its reason. Rewritten in place by /curate; no dates or changelog.

- Keep the README short: what it is, quick start, links. Put task-specific detail (deployment, security, configuration, contributing, releasing) in one-topic files under docs/, linked with a one-line "read this to..." description. Link instead of duplicating. Keep CLAUDE.md files lean the same way. Why: short entry points get read, long ones do not.
- Write for a reader who is new: plain, concise, accurate. No filler, no implementation trivia, no claims you have not checked against the code. Why: unchecked claims become trusted misinformation.
- User-level skills in ~/.claude/skills are general and must work across projects and companies: no company, product, project, host, path or domain-specific wording or examples in them. Company or project specific skills are different and may carry that context: name them `<company>-<skill-name>` (or `<company>-<project>-<skill-name>`) so the prefix marks them, or keep them in a plugin or the project's own .claude/skills. A plainly named user-level skill is always general. Why: a general skill that carries one team's vocabulary misleads and fails elsewhere.
