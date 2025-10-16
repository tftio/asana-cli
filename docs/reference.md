# Asana CLI Command Reference

This reference summarises every top-level command and the most frequently used
options. Use `--help` on any command for the authoritative, auto-generated
output.

## Global Flags

| Flag | Description |
|------|-------------|
| `--help` | Print context-sensitive help for the current command. |
| `--version` | Display the semantic version of the binary. |

## `config` Commands

| Subcommand | Purpose | Common Flags |
|------------|---------|--------------|
| `config set token` | Persist a Personal Access Token (PAT). | `--token <value>` (omit to be prompted securely) |
| `config set workspace` | Store or clear the default workspace gid. | `--workspace <gid>`, `--clear` |
| `config set assignee` | Store or clear the default assignee identifier. | `--assignee <id>`, `--clear` |
| `config get` | Show effective configuration values (PAT is redacted). | – |
| `config test` | Validate the PAT against Asana and report the user identity. | – |

## `project` Commands

| Subcommand | Purpose | Key Flags |
|------------|---------|-----------|
| `project list` | List projects in a workspace or team. | `--workspace <gid>`, `--team <gid>`, `--archived <bool>`, `--output <fmt>` |
| `project show <gid>` | Display detailed project information. | `--include-members`, `--status-limit <n>`, `--output <fmt>` |
| `project create` | Provision a project from CLI flags or templates. | `--workspace`, `--template`, `--member`, `--custom-field`, `--interactive` |
| `project update` | Modify project metadata. | `--name`, `--notes`, `--start-on`, `--due-on`, `--owner`, `--archive`, `--unarchive` |
| `project delete <gid>` | Delete a project (with confirmation). | `--force` |
| `project members ...` | Manage project membership. | `add`, `remove`, `list`, `update` |

## `task` Commands

| Subcommand | Purpose | Key Flags |
|------------|---------|-----------|
| `task list` | Enumerate tasks with flexible filtering. | `--workspace`, `--project`, `--assignee`, `--completed`, `--output` |
| `task show <gid>` | Display a task, including dependencies and subtasks. | `--output <fmt>` |
| `task create` | Create a task with natural language dates and custom fields. | `--workspace`, `--project`, `--due-on`, `--tag`, `--custom-field`, `--interactive` |
| `task update <gid>` | Update fields, toggle completion, or adjust relationships. | Flags mirror `task create` plus `--complete`, `--incomplete`, `--clear-*` options |
| `task delete <gid>` | Delete a task. | `--force` |
| `task create-batch` | Create many tasks from JSON/CSV. | `--file <path>`, `--format json|csv`, `--continue-on-error`, `--output` |
| `task update-batch` | Bulk update tasks from JSON/CSV. | Same as `create-batch` |
| `task complete-batch` | Mark many tasks complete/incomplete. | `--file`, `--format`, `--continue-on-error`, `--output` |
| `task search [query]` | Fuzzy-search tasks and optionally interactively select them. | `--workspace`, `--limit`, `--recent-only`, `--output` |
| `task subtasks ...` | Manage subtasks. | `list`, `create`, `convert` |
| `task depends-on ...` | Manage dependencies (tasks this task depends on). | `list`, `add`, `remove` |
| `task blocks ...` | Manage dependents (tasks blocked by this task). | `list`, `add`, `remove` |
| `task projects ...` | Add/remove project memberships. | `add`, `remove` |
| `task followers ...` | Add/remove followers. | `add`, `remove` |

## Miscellaneous Commands

| Command | Purpose |
|---------|---------|
| `completions <shell>` | Emit shell completion script content to stdout. |
| `manpage [--dir PATH]` | Render the bundled man page (writes to `PATH/asana-cli.1` if provided). |
| `doctor` | Run environment checks (tooling, versions, git-hooks). |
| `update` | Upgrade to the latest published release. |

For examples and guided workflows, see `docs/tutorial.md`.
