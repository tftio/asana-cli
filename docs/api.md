# API Client Overview

The Asana CLI ships with an async HTTP client tailored for the Asana REST API.
This document outlines how the client behaves and which configuration inputs it
respects.

## Authentication

- Personal Access Token (PAT) detection order:
  1. `ASANA_PAT` environment variable.
  2. Persisted token in `config.toml` (stored securely with restrictive file
     permissions).
  3. Interactive prompt via `config set token` when `--token` is not supplied.
- Tokens are transmitted using the `Authorization: Bearer <token>` header.
- Pre-push hooks run `gitleaks` to catch accidental PAT commits.

## Base URL & Workspaces

- Default base URL: `https://app.asana.com/api/1.0`.
- Override with `ASANA_BASE_URL` or `config` settings when targeting sandboxes
  or mock servers.
- `ASANA_WORKSPACE` or `config` defaults simplify `task` and `project` commands.
- `config set assignee` stores a preferred identifier (email or gid). Supplying
  `--assignee me` resolves to this value when present, otherwise the literal
  Asana alias "me" is forwarded.

## Rate Limiting & Retries

- The client is built on `reqwest` + `tokio` and automatically retries transient
  errors with exponential back-off.
- `Retry-After` headers are honoured; CLI error messages include suggested wait
  durations.
- Batch commands support `--continue-on-error` so partial successes are preserved.

## Caching & Offline Mode

- Responses from GET endpoints are cached under
  `~/.local/share/asana-cli/cache/` (or platform equivalent).
- `--offline` (future feature) will rely on cached responses exclusively.
- Cache TTL defaults to five minutes; entries are keyed by request + auth token.

## Pagination Helpers

- `ApiClient::paginate` and `paginate_with_limit` wrap Asana’s cursor-based
  pagination, streaming items until either the server indicates end-of-data or a
  client-side limit is met.
- CLI iterators (e.g., `task list`, `project list`) build upon these helpers.

## Error Surfacing

- Errors are mapped to descriptive variants (`ApiError`), providing context such
  as HTTP status, rate-limit metadata, or offline mode hints.
- Commands display user-friendly messages while returning a non-zero exit code.
- For verbose debugging, run with `RUST_LOG=asana_cli=debug`.

## Extending the Client

When adding new API surfaces:

1. Model the payloads in `src/models/` using Serde derives.
2. Add wrapper functions in `src/api/` that leverage `ApiClient`.
3. Surface new commands in the CLI modules, guarding any destructive
   operations with `--force` or confirmation prompts.
4. Update `docs/reference.md` and associated tests.

The design intentionally keeps the client in a reusable library crate (`asana-cli`)
to enable embedding in other tooling or integration tests.
