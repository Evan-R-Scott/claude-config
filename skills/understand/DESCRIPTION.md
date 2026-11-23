# Understand Files

Explain one or more files from a local repo to an intern or new team member. Pulls the repo's CLAUDE.md for context, finds the requested files, and walks through each one step by step with reasoning.

Also accepts a PR URL on any GitHub host - reads the diff and files through `gh` without touching your branch, explains every changed file, and adds a "What changed in this PR" section to each file explaining what was added/removed and why.

## Usage

```
/understand <repo-name> <file1> [file2] [file3] ...
/understand <pr-url>
```

## Examples

```
/understand example-repo packages/node-exporter/node-exporter-daemonset.yaml
/understand example-iac main.tf variables.tf
/understand example-repo packages/grafana-alloy/common-values.yaml clusters/example-cluster/grafana-alloy/values.yaml
/understand https://github.com/example-org/example-repo/pull/42
```

Repos live at `<repos-root>/<repo-name>`, where the repos root is the one you name (default: the parent of the current directory).
