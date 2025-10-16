# Asana CLI

Command-line tooling for working with Asana from the terminal. The binary is written in Rust and provides a modern subcommand-oriented interface that mirrors developer workflows.

## Features

- `config` subcommands for managing the Personal Access Token (PAT) and validating it against the Asana REST API.
- Resilient async API client with retry-aware networking, rate-limit handling, and disk-backed caching (including offline mode).
- Personal Access Token stored in the CLI configuration file or injected via the `ASANA_PAT` environment variable.
- Tokio-based runtime and `reqwest` client for API validation.
- Full project subcommands for list/show/create/update/delete plus members management.
- Multi-format output (table, JSON, CSV, Markdown) with rate-limit aware pagination.
- Template system with variable substitution and bundled defaults for rapid project bootstrapping.
- Saved filters, inline filtering, and sorting to tame large workspaces.
- Comprehensive automation via `just`, GitHub Actions, and git hooks.

## Installation

```bash
git clone https://github.com/tftio/asana-cli.git
cd asana-cli
cargo install --path .
```

Pre-built binaries will be published once the release workflow is enabled.

## Quick Start

```bash
# Display help
asana-cli help

# Store a Personal Access Token (prompted securely when --token is omitted)
asana-cli config set token --token "pat123"

# Inspect current configuration (token status is redacted)
asana-cli config get

# Validate the stored token against Asana
asana-cli config test

# Optional defaults for workspace/assignee
asana-cli config set workspace --workspace 1122334455
asana-cli config set assignee --assignee jfb@workhelix.com

# List projects in JSON (supports --output table|json|csv|markdown)
asana-cli project list --output json

# Show one project (includes members and recent status updates by default)
asana-cli project show 12345 --include-members

# Create a project from the bundled template with variable overrides
asana-cli project create \
  --template standard_project \
  --var project_name="CLI Demo" \
  --var workspace_gid="98765" \
  --var team_gid="76543" \
  --var owner_email="me@example.com"

# Override the API base URL (e.g. for mock servers) per command invocation
ASANA_BASE_URL="https://mock.example/api/1.0" asana-cli config test
```

## Shell Completions

Generate up-to-date completion files for every supported shell with:

```bash
just completions
```

The command writes files into `completions/` in the project root:

| Shell       | Generated file              | Installation hint                                                                                                              |
|-------------|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Bash        | `completions/asana-cli.bash` | Copy to `/etc/bash_completion.d/` (system-wide) or `~/.local/share/bash-completion/completions/` (user) and `source` in profile |
| Zsh         | `completions/_asana-cli`     | Copy to a directory listed in `$fpath` (e.g. `/usr/local/share/zsh/site-functions/`), then run `compinit`                       |
| Fish        | `completions/asana-cli.fish` | Copy to `~/.config/fish/completions/`                                                                                          |
| PowerShell  | `completions/asana-cli.ps1`  | Copy to `$PROFILE` directory (e.g. `~\Documents\PowerShell\Scripts\`) and `Add-Content $PROFILE ". $PWD\asana-cli.ps1"`      |

Regenerate the files whenever the CLI gains new commands or flags.

## Manual Page

Generate the roff-formatted man page with:

```bash
just manpage
```

The command writes `man/asana-cli.1`. Copy that file into a directory listed in
`$MANPATH` (for example `/usr/local/share/man/man1/`) and run `mandb` or
`makewhatis` to refresh the system index. You can then view it via:

```bash
man asana-cli
```

## Additional Documentation

- [docs/reference.md](docs/reference.md) – command matrix and flag overview.
- [docs/tutorial.md](docs/tutorial.md) – guided workflow for common setups.
- [docs/api.md](docs/api.md) – HTTP client behaviour, caching, and error handling.
- [docs/troubleshooting.md](docs/troubleshooting.md) – common issues and fixes.
- [docs/migration.md](docs/migration.md) – mapping web UI actions to CLI equivalents.

### Configuration Locations

| Platform      | Files                                               |
|---------------|-----------------------------------------------------|
| Linux/macOS   | `~/.config/asana-cli/config.toml` (config + PAT), `~/.local/share/asana-cli/cache/` (API cache), `~/.local/share/asana-cli/templates/` (templates), `~/.local/share/asana-cli/filters/` (saved filters) |
| Windows       | `%APPDATA%\asana-cli\config.toml` (config + PAT), `%LOCALAPPDATA%\asana-cli\cache\`, `%LOCALAPPDATA%\asana-cli\templates\`, `%LOCALAPPDATA%\asana-cli\filters\` |

Runtime overrides:

- `ASANA_PAT`, `ASANA_BASE_URL`, `ASANA_WORKSPACE`
- `ASANA_CLI_CONFIG_HOME`, `ASANA_CLI_DATA_HOME`

#### Token Storage & Permissions

- When a Personal Access Token is persisted via `config set token`, the CLI
  writes it to `config.toml` and tightens permissions on both the file
  (`0600`) and its directory (`0700`) on Unix-like platforms.
- Environment variables always take precedence, allowing ephemeral use without
  touching disk.
- Pre-push hooks run `gitleaks` to catch accidental credential commits.

### Security

- `just pre-push` (and the configured git hook) executes `cargo audit`
  alongside secret scanning to flag vulnerable dependencies before code
  leaves your machine.
- You can run the audit manually at any time:

  ```bash
  cargo audit
  ```

- Configuration directories are created with restrictive permissions, and the
  on-disk PAT is redacted in debug output to minimise accidental exposure.
- `config set workspace` and `config set assignee` store plain string defaults.
  Clearing them (`--clear`) removes the value. When a default assignee is set,
  passing `--assignee me` (or omitting `--assignee` for `task list`) expands to
  the configured identifier.

#### Personal Access Token Management

- `ASANA_PAT` (when set and non-empty) has highest priority and completely bypasses any token stored on disk.
- `asana-cli config set token` persists the PAT into `config.toml`; edit the file or rerun the command with a new value to rotate credentials.
- `asana-cli config get` confirms whether the active token originated from env or disk without revealing the secret.
- To remove a persisted token, delete the `personal_access_token` field from `config.toml` (future work will add `config delete token` once lifecycle flows are finalised).

### Filters & Templates

- Saved filters live under `~/.local/share/asana-cli/filters/` (`filters/` on Windows) as `.filters` files. Use `--save-filter name` with `project list` to persist expressions such as `--filter "workspace={{workspace_gid}}"`.
- Templates load from `~/.local/share/asana-cli/templates/` and support placeholders like `{{project_name}}`. Bundled defaults are installed automatically (for example `standard_project.toml`). Supply `--var KEY=VALUE` during `project create` to replace placeholders.

## Development

### Requirements

- Rust 1.85.0 or newer (`rustup default 1.85.0`)
- `just` for command automation
- `peter-hook` (`cargo install peter-hook`) for the provided git hooks
- `versioneer` (`cargo install versioneer`) for version management

### Common Commands

```bash
# Install hooks and project prerequisites
just setup

# Run formatting, linting, and tests
just quality

# Execute individual steps
just format-check
just lint
just test

# Build binaries
just build
just build-release
```

> **Note:** `cargo clippy` is currently tracked upstream for sporadic Apple silicon crashes when run under the pre-commit hook. If you hit the issue, run the lint directly (`just lint`). A fix will follow once the rustc-side bug is resolved.

### Versioning & Releases

Versions are bumped exclusively through `versioneer`. A Phase 5 release flow will wire `just release` to GitHub Actions for automated tagging and binary publication.

```bash
versioneer patch   # or minor / major
versioneer tag --tag-format "asana-cli-v{version}"
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for coding standards, branching strategy, and review expectations.

## License

MIT. See [LICENSE](LICENSE) for full text.
