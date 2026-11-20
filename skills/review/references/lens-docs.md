# Lens: documentation

A document is wrong if a new reader following it would end up somewhere else. Check it against the thing it describes, not against itself.

- **Accuracy:** for every claim, command, path, flag, option, URL, version and number: check it against the code or system it describes. Run the commands only for a trusted target and in the E5 copy (otherwise `bash -n` them or check them by reading and list them under Verification Results), confirm every file path and config key exists, follow every link and in-page anchor (a renamed heading breaks its table-of-contents link).
- **Completeness:** can a new reader do the task end to end with only this? Missing prerequisites, steps in the wrong order, undefined terms, an unstated environment (OS, shell, version).
- **Currency:** does it still describe the current behavior, or something removed or renamed? Search the repo for the old name.
- **Claims not checked against the code:** flag them. Do not accept "it works like this" without evidence.
- **Audience and length:** plain, concise, for a reader who is new. No filler, no implementation trivia, no history in a how-to. A README stays short and links to one-topic docs.
- **Duplication:** the same fact in two places will drift; link instead of repeating.
- **Style the project asks for:** read the project's `CLAUDE.md` or `AGENTS.md` and any contributing guide for documentation rules and apply them (for example a dash convention, where detail belongs).
- **Safe examples:** no secrets, personal data or internal-only hosts in examples that will be shared.
