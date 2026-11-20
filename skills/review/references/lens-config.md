# Lens: configuration, build and infrastructure files

Never apply anything. Validate with the tool's own validator inside the E5 copy: YAML/JSON parse, `terraform validate`, `ansible --list-tasks`, `helm lint`, `docker compose config`, `actionlint`, `bash -n`.

- **Correctness:** does it do what it claims, in the environment it will run in? Wrong keys, indentation, types, defaults, ordering, escaping, and values that differ between environments.
- **Secrets and access:** secrets hardcoded or logged; overly broad permissions, open ports, wildcard principals; credentials in untracked files about to be added.
- **Safety of change:** can it be rolled back? Does it change shared or production state, drop data, or require a manual step to take effect?
- **Idempotence and drift:** applying twice gives the same result; no hidden dependency on local state.
- **Pinning and supply chain:** unpinned versions, `latest` tags, unverified downloads, running remote scripts.
- **CI specifics:** triggers, permissions of the workflow token, caching keys, which branches run what, and whether a failing step really fails the job.
- **Consistency:** the same value defined in several places; names that do not match what they refer to.
- **SQL migrations:** locking and table rewrites on big tables, backward compatibility with the code that is still deployed (rolling deploys), reversibility, data loss, ordering against other migrations, and whether it was run against a copy.
