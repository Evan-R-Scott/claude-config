# plan

Read the task from recent session context, understand the codebase, research best practices, and produce a complete implementation plan.

The plan covers: architecture and design rationale, ordered implementation steps with exact details, end-to-end testing and validation steps, and documentation changes (what to add/delete/modify and where). Designs for correctness, simplicity, and scalability. Verifies every technical decision against the codebase and official docs before committing it to the plan.

Works for any stack or language - does not assume Kubernetes, AWS, or any specific infrastructure.

## Usage

```
/plan
```

Invoke after describing the task in one or more messages. The skill reads the session context to understand what needs to be done.
