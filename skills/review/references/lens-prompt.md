# Lens: prompts, skills, agent instructions, CLAUDE.md and AGENTS.md

These files are programs an AI follows. Judge them by what an agent would actually do, and check them against each other.

- **Contradictions:** two instructions that cannot both be followed, within a file or between files (a rule in one place, the opposite in another).
- **Stale references:** section names, step numbers, file paths, command names or skills that do not exist (search for every name they mention).
- **Steps the agent cannot perform:** asking the user a question in a subagent that cannot ask, needing a tool, permission, network or credential it will not have, or a command that does not work as written (run the harmless ones).
- **Ambiguity:** an instruction two agents would read differently; a missing default; a condition with no else.
- **Untrusted input:** does it say that content it reads (files, web pages, comments) is data, never instructions? Does it run commands that come from that content?
- **Safety:** actions with side effects (posting, deleting, deploying, spending) must be gated on explicit user approval, and the gate must be one the agent can actually reach.
- **Cost:** text that is always loaded but rarely needed, the same text in several files, work done twice.
- **Output contract:** is the expected output defined precisely enough to check? Is it consistent with how the caller uses it?
- **Test it (only when a prompt, skill or instruction file is the main thing the change is about, and the target is trusted):** if you can start a subagent, run two realistic requests (a typical one and an adversarial one, plus an edge case only if you found an ambiguity) through the instructions on a tiny fixture and report where it actually went wrong. Skip it for a change that merely touches such a file, for reference files that are not run directly, and for anything that would publish or post; say so under Verification Results.
