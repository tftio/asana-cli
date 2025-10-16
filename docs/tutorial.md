# Getting Started Tutorial

This tutorial walks through a realistic setup for a new engineering project.
It assumes you already generated a Personal Access Token (PAT) from Asana.

## 1. Install and Configure

```bash
git clone https://github.com/tftio/asana-cli.git
cd asana-cli
cargo install --path .

# Configure the CLI
asana-cli config set token --token "pat123"
asana-cli config set workspace --workspace 1122334455
asana-cli config set assignee --assignee you@example.com
asana-cli config test
```

The first command securely stores the PAT in the configuration file; the second
verifies it against the API.

## 2. Discover Projects

List projects in the engineering workspace and render them as a table:

```bash
asana-cli project list --workspace 1122334455 --output table
```

Save a handy filter for future use (stored in `~/.local/share/asana-cli/filters/`):

```bash
asana-cli project list \
  --workspace 1122334455 \
  --filter "owner.email=manager@example.com" \
  --save-filter engineering-owned
```

## 3. Bootstrap a New Project

Use the bundled template and override a few variables:

```bash
asana-cli project create \
  --template standard_project \
  --var project_name="CLI Rollout" \
  --var workspace_gid=1122334455 \
  --var team_gid=55667788 \
  --var owner_email=lead@example.com \
  --interactive
```

The `--interactive` flag prompts for any missing values. After creation, grab
the project gid from the output.

## 4. Create Tasks

Single task:

```bash
asana-cli task create \
  --workspace 1122334455 \
  --project 99887766 \
  --name "Draft CLI announcement" \
  --due-on "next Friday" \
  --tag "communications" \
  --custom-field priority="High"
```

Batch creation from a JSON plan:

```bash
cat <<'JSON' > rollout-tasks.json
[
  {
    "name": "Publish documentation",
    "workspace": "1122334455",
    "projects": ["99887766"],
    "due_on": "in two weeks"
  },
  {
    "name": "Record internal demo",
    "workspace": "1122334455",
    "projects": ["99887766"],
    "assignee": "devrel@example.com",
    "tags": ["enablement"]
  }
]
JSON

asana-cli task create-batch --file rollout-tasks.json --format json --output table
```

## 5. Track Progress

List assigned tasks, highlighting completion and dependencies:

```bash
asana-cli task list --project 99887766 --assignee me --output table
```

Fuzzy-search across recent changes:

```bash
asana-cli task search "announcement" --workspace 1122334455 --limit 20
```

Mark tasks complete in bulk:

```bash
cat <<'CSV' > completions.csv
task,completed
1200000000001,true
1200000000002,true
CSV
asana-cli task complete-batch --file completions.csv --format csv
```

## 6. Automate

Add an entry to the `justfile` for quick reporting:

```just
report:
    asana-cli task list --project 99887766 --assignee me --output table
```

Now `just report` delivers an up-to-date task view.

---

Explore `docs/reference.md` for the full command matrix and
`docs/troubleshooting.md` if you hit snags.
