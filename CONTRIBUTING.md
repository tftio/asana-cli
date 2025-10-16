# Contributing to Asana CLI

Thanks for helping build the Asana CLI. This document summarises the expectations for pull requests during Phase 1.

## Development Workflow

1. Fork and clone the repository.
2. Create a feature branch from `main`.
3. Use the provided `just` recipes (`just dev`, `just quality`, `just test`).
4. Ensure `cargo fmt`, `cargo clippy`, and `cargo test` pass before committing.
5. Commit using Conventional Commit messages.
6. Run `versioneer patch` (or `minor`/`major` when instructed) for every change set.
7. Open a pull request against `main`.

## Coding Standards

- Rust 2024 edition, MSRV 1.85.0.
- `cargo fmt --all` (nightly toolchain) and `cargo clippy --all-targets -- -D warnings`.
- Public APIs documented (`missing_docs = "deny"`).
- Avoid panics in library code; propagate errors via `anyhow::Result`.
- Adhere to existing module layout (`src/cli`, `src/config`, `src/doctor`, etc.).

## Testing

- Unit tests co-located with modules.
- Integration tests in `tests/`, executed via `cargo test`.
- Avoid network calls in tests (mock or inject where necessary) – the current suite keeps token validation offline.
- CLI integration tests use `mockito`; ensure nothing is already listening on the chosen loopback ports when running `cargo test`.

## Git Hooks & Tooling

- Install hooks with `just install-hooks`.
- Hooks run formatting, clippy, tests, and version checks via `peter-hook`.
- If clippy aborts on Apple silicon, document the failure in the pull request and include manual lint output.

## Versioning

- Never edit `Cargo.toml` or `VERSION` manually.
- Run `versioneer patch|minor|major` and add the resulting files to commits.
- Tag creation is deferred to the release workflow.

## Documentation

- Keep `README.md` in sync with new CLI commands.
- Update `docs/plans/asana-cli/phase_X.md` checkboxes as tasks complete.
- Include user-facing changes in `CHANGELOG.md` when the release process is enabled.

## Security & Secrets

- Do not commit PATs or other credentials.
- Use environment variables + fallback passphrase when testing `config set token` locally.
- Report security issues privately to the maintainer (jfb@workhelix.com).

Questions? Open an issue or start a discussion on GitHub. Thanks for contributing!
