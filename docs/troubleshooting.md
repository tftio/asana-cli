# Troubleshooting Guide

Common issues and their resolutions when using the Asana CLI.

## Authentication Failures

**Symptom:** `config test` returns `authentication failed`.

- Verify the PAT is valid in the Asana web UI.
- Re-run `asana-cli config set token` without `--token` to be prompted securely.
- Check for an overriding `ASANA_PAT` environment variable (`printenv ASANA_PAT`).

## `cargo audit` or `gitleaks` Hook Fails

- The pre-push hook runs both tools. Install them if missing:
  ```bash
  cargo install cargo-audit
  brew install gitleaks # or use the official release binaries
  ```
- For `gitleaks` hits, review the referenced file/line and remove any secrets
  before recommitting.

## Rate Limit Errors

Asana enforces API rate limits. Retry after the `Retry-After` hint reported in
error messages. Batch commands support `--continue-on-error` to persist
alongside rate-limit spikes.

## SSL or Networking Errors

- Ensure `ASANA_BASE_URL` is not pointing at an internal mock that lacks TLS.
- Corporate proxies may require additional environment variables (`https_proxy`).

## Permission Denied Writing `config.toml`

The CLI tightens directory and file permissions (700/600). If you run in a
shared environment, ensure the config directory is owned by your user or set
`ASANA_CLI_CONFIG_HOME` to a writable location.

## Missing Projects or Tasks

Confirm the workspace gid is correct. Use the web UI to copy the gid from the
address bar (`https://app.asana.com/0/<workspace>/<project>`). When filtering,
combine flags carefully (`--workspace` and `--project` simultaneously restrict
results).

If commands appear to ignore `--assignee me`, ensure you've stored the default
assignee (`asana-cli config set assignee --assignee you@example.com`). Otherwise
the CLI forwards the literal `me` alias to Asana.

## CLI Crashes or Panic Output

Run with `RUST_BACKTRACE=1` to provide more context when filing an issue:

```bash
RUST_BACKTRACE=1 asana-cli task list --workspace 1122334455
```

## Need More Help?

- `asana-cli help <command>` for immediate usage info.
- `docs/tutorial.md` for guided workflows.
- File issues with reproduction steps and CLI version (`asana-cli version`).
