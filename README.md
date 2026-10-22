# GOV.UK Once Laptop Configuration

Instructions on how to configure your GDS supplied developer laptop for use in GOV.UK Once.

The tools and scripts are generic and designed to aid users in their initial setup, it is advised that users review the software and scripts to ensure they understand what is being installed.

Contributions are welcome.


## Install base tools
Install Homebrew: [https://brew.sh/](https://brew.sh/)

## Setup your laptop
Install base tools
```bash
brew bundle --file=./brewfile
```

## Run configuration scripts

The `setup.sh` script will configure git and the gds-cli with commonly used settings, it is recommended you review the setup.sh script and understand the changes before running.
```bash
./setup.sh
```

## Claude Code configuration (optional)

`claude/` holds an opinionated, context-efficient Claude Code setup for Terraform, YAML, bash and TypeScript work.
It contains a global `CLAUDE.md`, path-scoped rules, hooks, subagents and skills.

| Path | Purpose |
|------|---------|
| `claude/rules/` | Guidance that loads only when Claude touches matching files (`*.tf`, `*.yaml`, `*.sh`, `*.ts`, `*.md`). |
| `claude/hooks/` | Format and lint on edit, block edits to generated files, block context-flooding or unsafe commands. Silent on success. |
| `claude/agents/` | Subagents that do heavy reading in their own context and return short summaries. |
| `claude/skills/` | `tf-plan-summary`, `pr-ready`, `gh-digest`, `jira`. |
| `claude/settings.template.json` | Hook wiring, permissions and env settings, without credentials. |

Review the files, then link them into `~/.claude` (existing files are backed up first):

```bash
./claude/install.sh
```

`settings.json` is never linked because it holds machine-specific credentials.
Merge `claude/settings.template.json` into `~/.claude/settings.json` by hand.

## Install NPM

## Install NX
