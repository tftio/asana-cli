# Migrating from the Asana Web UI

This guide maps common web UI workflows to their CLI equivalents so you can
transition to terminal-centric task management.

## Navigation & Discovery

| Web UI | CLI Equivalent |
|--------|----------------|
| Sidebar workspace/project list | `asana-cli project list --workspace <gid>` |
| Project dashboard | `asana-cli project show <project-gid> --include-members --output table` |
| Task search box | `asana-cli task search "keywords" --workspace <gid>` |

## Creating Work

| Web UI Action | CLI Command |
|---------------|-------------|
| New project via template | `asana-cli project create --template standard_project --var ...` |
| New blank project | `asana-cli project create --workspace <gid> --name "Project"` |
| New task (inline) | `asana-cli task create --project <gid> --name "Task" --due-on "tomorrow"` |
| Bulk import CSV | `asana-cli task create-batch --file tasks.csv --format csv` |

## Editing & Collaboration

| Web UI | CLI |
|--------|-----|
| Assign task | `asana-cli task update <task> --assignee email@example.com` |
| Complete task | `asana-cli task update <task> --complete` or batch variant |
| Add followers | `asana-cli task followers add <task> --follower user@example.com` |
| Reassign to project section | `asana-cli task projects add <task> --project <gid> --section <section-gid>` |
| Manage dependencies | `asana-cli task depends-on add <task> --dependency <gid>` |

## Views & Reporting

| Web UI | CLI |
|--------|-----|
| Saved report | `asana-cli project list --filter-saved name` or `task list` with scripted filters |
| Timeline view | Export data via `task list --output json` and feed into custom tooling (e.g., Gantt charts) |
| Custom fields column | Include via `task show` / `task list` outputs (fields rendered in JSON/Markdown) |

## Notifications & Activity

| Web UI | CLI |
|--------|-----|
| Inbox updates | `asana-cli task list --assignee me --completed false --output table` |
| Project status updates | `asana-cli project show <gid> --status-limit 5 --output json` |

## Tips for a Smooth Transition

1. **Alias frequent commands:** Add entries to your shell (`alias al='asana-cli task list ...'`).
2. **Use saved filters and batch files** to replicate recurring reports or imports.
3. **Integrate with scripts/CI** via JSON output for automation pipelines.
4. **Store defaults:** `config set workspace --workspace <gid>` and
   `config set assignee --assignee you@example.com` streamline day-to-day
   commands (`--assignee me` uses the stored value).
5. **Manpage & reference:** `man asana-cli`, `docs/reference.md` for quick lookup.
6. **Keep PAT secure:** environment variable overrides avoid touching disk on
   shared machines.

With these mappings you can accomplish everyday Asana tasks directly from the
terminal while retaining the web UI for occasional visual workflows.
