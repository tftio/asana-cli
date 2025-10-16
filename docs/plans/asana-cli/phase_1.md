# Phase 1: Foundation and Setup

## Explanation

Establish the project structure, development environment, and core configuration management system. This phase creates the skeleton that all subsequent features will build upon, including persistent token storage, configuration file handling, and the basic CLI argument parsing framework.

## Rationale

Starting with a solid foundation prevents technical debt and rework. By implementing configuration and security patterns first, we ensure that:
- Authentication tokens are never exposed in logs or error messages
- The CLI follows established patterns from the monorepo (consistency)
- Development tooling is in place for rapid iteration
- Cross-platform compatibility is validated early

## Brief

Create a new Rust CLI project with proper structure, implement secure configuration management with TOML files and opt-in environment overrides, set up the development environment with `just` commands, and establish the basic CLI interface with clap v4.

## TODO Checklist

- [x] Initialize Rust project structure with `cargo new asana-cli`
- [x] Add core dependencies to Cargo.toml:
  - [x] `clap` v4 with derive feature for CLI parsing
  - [x] `tokio` with full features for async runtime
  - [x] `serde` and `serde_json` for serialization
  - [x] `toml` for configuration files
  - [x] `directories` for XDG-compliant paths
  - [x] `anyhow` for error handling
  - [x] `tracing` for structured logging
- [x] Create project structure:
  - [x] `src/main.rs` - Entry point with CLI setup
  - [x] `src/lib.rs` - Library root for testing
  - [x] `src/config.rs` - Configuration management
  - [x] `src/error.rs` - Custom error types
  - [x] `src/cli/mod.rs` - CLI command structure
- [x] Implement configuration module:
  - [x] TOML file parsing at `~/.config/asana-cli/config.toml`
  - [x] Environment variable override support
  - [x] Config validation and migration
- [x] Set up token handling:
  - [x] Persist PATs in configuration when provided interactively
  - [x] Token redaction in Debug implementations
  - [x] Secure input prompting with rpassword
- [x] Create CLI skeleton:
  - [x] Main command with version and help
  - [x] `config` subcommand for setup
  - [x] `task` subcommand placeholder
  - [x] `project` subcommand placeholder
- [x] Implement `config` commands:
  - [x] `config set token` - Persist PAT to config file
  - [x] `config get` - Show configuration (token redacted)
  - [x] `config test` - Validate token with API
- [x] Add development tooling:
  - [x] Create `justfile` with standard commands
  - [x] Add `.github/workflows/ci.yml` for CI
  - [x] Configure clippy with pedantic lints
  - [x] Set up rustfmt.toml
- [x] Write initial tests:
  - [x] Configuration loading and validation
  - [x] Token storage and retrieval
  - [x] CLI argument parsing
- [x] Create initial documentation:
  - [x] README.md with setup instructions
  - [x] CONTRIBUTING.md with development guide

## Definition of Done

- Project builds with `cargo build --release`
- Can store and retrieve PAT via configuration or environment overrides
- Configuration persists across sessions
- All tests pass with `cargo test`
- CI pipeline runs successfully
- No sensitive data in logs or errors
