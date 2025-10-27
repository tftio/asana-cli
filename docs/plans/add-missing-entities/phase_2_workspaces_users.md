# Phase 2: Workspaces & Users

**Priority**: HIGH
**Status**: 📋 Planned
**Estimated Effort**: 6-8 hours
**Dependencies**: None

## Overview

Implement workspace and user discovery features. This is foundational functionality that enables discovering what workspaces you have access to, who the members are, and retrieving user information.

**User Value**: "I need to see what workspaces I'm in" or "Who is user 123456789?" or "Find all users named Sarah in my workspace"

## Scope

### In Scope
- List workspaces for current user
- Get workspace details
- List users in a workspace
- Get user details
- Get current user info
- Search users by name/email

### Out of Scope
- Workspace creation/deletion (typically admin-only)
- Workspace settings management
- User task lists (future enhancement)
- User favorites (future enhancement)
- Workspace invitations

## Asana API Endpoints

| Method | Endpoint | Purpose | Scope Required |
|--------|----------|---------|----------------|
| GET | `/workspaces` | List user's workspaces | default |
| GET | `/workspaces/{workspace_gid}` | Get workspace details | default |
| GET | `/workspaces/{workspace_gid}/users` | List users in workspace | default |
| GET | `/users` | Get multiple users | default |
| GET | `/users/{user_gid}` | Get user details | default |
| GET | `/users/me` | Get current user | default |

## Data Models

### File: `src/models/workspace.rs` (extend existing)

```rust
//! Workspace and team references.

use serde::{Deserialize, Serialize};

/// Lightweight workspace reference (already exists).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct WorkspaceReference {
    pub gid: String,
    #[serde(default)]
    pub name: Option<String>,
    #[serde(default)]
    pub resource_type: Option<String>,
}

impl WorkspaceReference {
    #[must_use]
    pub fn label(&self) -> String {
        self.name.clone().unwrap_or_else(|| self.gid.clone())
    }
}

/// Full workspace payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Workspace {
    /// Globally unique identifier.
    pub gid: String,
    /// Workspace name.
    pub name: String,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Email domains for organization (if applicable).
    #[serde(default)]
    pub email_domains: Vec<String>,
    /// Whether workspace is an organization.
    #[serde(default)]
    pub is_organization: bool,
}

/// Parameters for listing workspaces.
#[derive(Debug, Clone, Default)]
pub struct WorkspaceListParams {
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}
```

### File: `src/models/user.rs` (extend existing)

```rust
//! User data structures.

use serde::{Deserialize, Serialize};

/// Lightweight user reference (already exists).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct UserReference {
    pub gid: String,
    #[serde(default)]
    pub name: Option<String>,
    #[serde(default)]
    pub resource_type: Option<String>,
}

impl UserReference {
    #[must_use]
    pub fn label(&self) -> String {
        self.name.clone().unwrap_or_else(|| self.gid.clone())
    }
}

/// User identity with email (already exists).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct UserIdentity {
    pub gid: String,
    #[serde(default)]
    pub name: Option<String>,
    #[serde(default)]
    pub email: Option<String>,
    #[serde(default)]
    pub resource_type: Option<String>,
}

/// Full user payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct User {
    /// Globally unique identifier.
    pub gid: String,
    /// User's name.
    pub name: String,
    /// Email address.
    #[serde(default)]
    pub email: Option<String>,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Photo URLs.
    #[serde(default)]
    pub photo: Option<UserPhoto>,
    /// Workspaces user is member of.
    #[serde(default)]
    pub workspaces: Vec<WorkspaceReference>,
}

/// User photo URLs.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct UserPhoto {
    #[serde(rename = "image_21x21")]
    pub image_21x21: Option<String>,
    #[serde(rename = "image_27x27")]
    pub image_27x27: Option<String>,
    #[serde(rename = "image_36x36")]
    pub image_36x36: Option<String>,
    #[serde(rename = "image_60x60")]
    pub image_60x60: Option<String>,
    #[serde(rename = "image_128x128")]
    pub image_128x128: Option<String>,
}

/// Parameters for listing users.
#[derive(Debug, Clone, Default)]
pub struct UserListParams {
    /// Workspace to list users from.
    pub workspace: String,
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}

/// Parameters for searching users.
#[derive(Debug, Clone)]
pub struct UserSearchParams {
    /// Workspace to search in.
    pub workspace: String,
    /// Search query (matches name and email).
    pub query: String,
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}
```

## API Operations

### File: `src/api/workspaces.rs` (new)

```rust
//! High level workspace operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{Workspace, WorkspaceListParams, WorkspaceReference},
};
use futures_util::{pin_mut, StreamExt};
use serde::Deserialize;

/// List workspaces for the current user.
pub async fn list_workspaces(
    client: &ApiClient,
    params: WorkspaceListParams,
) -> Result<Vec<Workspace>, ApiError> {
    let stream = client.paginate_with_limit::<Workspace>("/workspaces", vec![], params.limit);
    pin_mut!(stream);

    let mut workspaces = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        workspaces.append(&mut page);
    }

    Ok(workspaces)
}

/// Get a single workspace.
pub async fn get_workspace(client: &ApiClient, gid: &str) -> Result<Workspace, ApiError> {
    let response: SingleWorkspaceResponse = client
        .get_json_with_pairs(&format!("/workspaces/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

#[derive(Debug, Deserialize)]
struct SingleWorkspaceResponse {
    data: Workspace,
}
```

### File: `src/api/users.rs` (new)

```rust
//! High level user operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{User, UserListParams, UserSearchParams},
};
use futures_util::{pin_mut, StreamExt};
use serde::Deserialize;

/// List users in a workspace.
pub async fn list_users(
    client: &ApiClient,
    params: UserListParams,
) -> Result<Vec<User>, ApiError> {
    let endpoint = format!("/workspaces/{}/users", params.workspace);
    let stream = client.paginate_with_limit::<User>(&endpoint, vec![], params.limit);
    pin_mut!(stream);

    let mut users = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        users.append(&mut page);
    }

    Ok(users)
}

/// Get a single user.
pub async fn get_user(client: &ApiClient, gid: &str) -> Result<User, ApiError> {
    let response: SingleUserResponse = client
        .get_json_with_pairs(&format!("/users/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

/// Get the current authenticated user.
pub async fn get_current_user(client: &ApiClient) -> Result<User, ApiError> {
    let response: SingleUserResponse = client
        .get_json_with_pairs("/users/me", vec![])
        .await?;
    Ok(response.data)
}

/// Search for users in a workspace.
pub async fn search_users(
    client: &ApiClient,
    params: UserSearchParams,
) -> Result<Vec<User>, ApiError> {
    // Get all users and filter client-side (Asana API doesn't have search endpoint)
    let list_params = UserListParams {
        workspace: params.workspace,
        limit: None, // Get all for accurate search
    };

    let mut users = list_users(client, list_params).await?;

    let query_lower = params.query.to_lowercase();
    users.retain(|user| {
        user.name.to_lowercase().contains(&query_lower)
            || user.email.as_ref().map_or(false, |e| e.to_lowercase().contains(&query_lower))
    });

    if let Some(limit) = params.limit {
        users.truncate(limit);
    }

    Ok(users)
}

#[derive(Debug, Deserialize)]
struct SingleUserResponse {
    data: User,
}
```

## CLI Commands

### File: `src/cli/workspace.rs` (new)

```rust
//! Workspace CLI command implementations.

use super::build_api_client;
use crate::{
    api,
    config::Config,
    error::Result,
    models::{User, UserListParams, Workspace, WorkspaceListParams},
};
use anyhow::Context;
use clap::{Args, Subcommand, ValueEnum};
use colored::Colorize;
use std::io::{IsTerminal, stdout};
use tokio::runtime::Builder as RuntimeBuilder;

#[derive(Subcommand, Debug)]
pub enum WorkspaceCommand {
    /// List workspaces.
    List(WorkspaceListArgs),
    /// Show workspace details.
    Show(WorkspaceShowArgs),
    /// List users in a workspace.
    Users(WorkspaceUsersArgs),
}

#[derive(Args, Debug)]
pub struct WorkspaceListArgs {
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum, default_value = "table")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct WorkspaceShowArgs {
    /// Workspace identifier.
    #[arg(value_name = "WORKSPACE")]
    pub workspace: String,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct WorkspaceUsersArgs {
    /// Workspace identifier.
    #[arg(value_name = "WORKSPACE")]
    pub workspace: String,
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum, default_value = "table")]
    pub format: OutputFormat,
}

#[derive(Debug, Clone, Copy, ValueEnum)]
pub enum OutputFormat {
    Table,
    Detail,
    Json,
}

pub fn handle_workspace_command(command: WorkspaceCommand, config: &Config) -> Result<()> {
    let runtime = RuntimeBuilder::new_current_thread()
        .enable_all()
        .build()
        .context("failed to initialise async runtime")?;

    match command {
        WorkspaceCommand::List(args) => runtime.block_on(handle_workspace_list(args, config)),
        WorkspaceCommand::Show(args) => runtime.block_on(handle_workspace_show(args, config)),
        WorkspaceCommand::Users(args) => runtime.block_on(handle_workspace_users(args, config)),
    }
}

async fn handle_workspace_list(args: WorkspaceListArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;
    let params = WorkspaceListParams { limit: args.limit };
    let workspaces = api::list_workspaces(&client, params)
        .await
        .context("failed to list workspaces")?;

    match args.format {
        OutputFormat::Table => render_workspace_table(&workspaces),
        OutputFormat::Detail => {
            for ws in &workspaces {
                render_workspace_detail(ws);
                println!();
            }
        }
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&workspaces)?;
            println!("{json}");
        }
    }

    Ok(())
}

async fn handle_workspace_show(args: WorkspaceShowArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;
    let workspace = api::get_workspace(&client, &args.workspace)
        .await
        .context("failed to get workspace")?;

    match args.format {
        OutputFormat::Detail | OutputFormat::Table => render_workspace_detail(&workspace),
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&workspace)?;
            println!("{json}");
        }
    }

    Ok(())
}

async fn handle_workspace_users(args: WorkspaceUsersArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;
    let params = UserListParams {
        workspace: args.workspace,
        limit: args.limit,
    };
    let users = api::list_users(&client, params)
        .await
        .context("failed to list users")?;

    match args.format {
        OutputFormat::Table => render_user_table(&users),
        OutputFormat::Detail => {
            for user in &users {
                render_user_detail(user);
                println!();
            }
        }
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&users)?;
            println!("{json}");
        }
    }

    Ok(())
}

fn render_workspace_table(workspaces: &[Workspace]) {
    if workspaces.is_empty() {
        println!("No workspaces found.");
        return;
    }

    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{:<20} {:<40} {}", "GID".bold(), "Name".bold(), "Type".bold());
        println!("{}", "─".repeat(70));
    }

    for ws in workspaces {
        let ws_type = if ws.is_organization { "Organization" } else { "Workspace" };
        if is_tty {
            println!("{:<20} {:<40} {}", ws.gid, ws.name, ws_type);
        } else {
            println!("{}\t{}\t{}", ws.gid, ws.name, ws_type);
        }
    }

    if is_tty {
        println!("\n{} workspaces listed.", workspaces.len());
    }
}

fn render_workspace_detail(ws: &Workspace) {
    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{}", "Workspace Details".bold().underline());
        println!("  {}: {}", "GID".bold(), ws.gid);
        println!("  {}: {}", "Name".bold(), ws.name);
        println!("  {}: {}", "Type".bold(), if ws.is_organization { "Organization" } else { "Workspace" });
        if !ws.email_domains.is_empty() {
            println!("  {}: {}", "Email Domains".bold(), ws.email_domains.join(", "));
        }
    } else {
        println!("GID: {}", ws.gid);
        println!("Name: {}", ws.name);
        println!("Type: {}", if ws.is_organization { "Organization" } else { "Workspace" });
        if !ws.email_domains.is_empty() {
            println!("Email Domains: {}", ws.email_domains.join(", "));
        }
    }
}

fn render_user_table(users: &[User]) {
    if users.is_empty() {
        println!("No users found.");
        return;
    }

    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{:<20} {:<30} {}", "GID".bold(), "Name".bold(), "Email".bold());
        println!("{}", "─".repeat(70));
    }

    for user in users {
        let email = user.email.as_deref().unwrap_or("(no email)");
        if is_tty {
            println!("{:<20} {:<30} {}", user.gid, user.name, email);
        } else {
            println!("{}\t{}\t{}", user.gid, user.name, email);
        }
    }

    if is_tty {
        println!("\n{} users listed.", users.len());
    }
}

fn render_user_detail(user: &User) {
    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{}", "User Details".bold().underline());
        println!("  {}: {}", "GID".bold(), user.gid);
        println!("  {}: {}", "Name".bold(), user.name);
        if let Some(email) = &user.email {
            println!("  {}: {}", "Email".bold(), email);
        }
        if !user.workspaces.is_empty() {
            println!("  {}:", "Workspaces".bold());
            for ws in &user.workspaces {
                println!("    - {} ({})", ws.label(), ws.gid);
            }
        }
    } else {
        println!("GID: {}", user.gid);
        println!("Name: {}", user.name);
        if let Some(email) = &user.email {
            println!("Email: {}", email);
        }
    }
}
```

### File: `src/cli/user.rs` (new)

```rust
//! User CLI command implementations.

use super::build_api_client;
use crate::{
    api,
    config::Config,
    error::Result,
    models::{User, UserSearchParams},
};
use anyhow::{Context, anyhow};
use clap::{Args, Subcommand, ValueEnum};
use colored::Colorize;
use std::io::{IsTerminal, stdout};
use tokio::runtime::Builder as RuntimeBuilder;

#[derive(Subcommand, Debug)]
pub enum UserCommand {
    /// Show user details.
    Show(UserShowArgs),
    /// Search for users.
    Search(UserSearchArgs),
    /// Show current authenticated user.
    Me(UserMeArgs),
}

#[derive(Args, Debug)]
pub struct UserShowArgs {
    /// User identifier or "me" for current user.
    #[arg(value_name = "USER")]
    pub user: String,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct UserSearchArgs {
    /// Search query (matches name and email).
    #[arg(long)]
    pub query: String,
    /// Workspace to search in.
    #[arg(long)]
    pub workspace: Option<String>,
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum, default_value = "table")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct UserMeArgs {
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: OutputFormat,
}

#[derive(Debug, Clone, Copy, ValueEnum)]
pub enum OutputFormat {
    Table,
    Detail,
    Json,
}

pub fn handle_user_command(command: UserCommand, config: &Config) -> Result<()> {
    let runtime = RuntimeBuilder::new_current_thread()
        .enable_all()
        .build()
        .context("failed to initialise async runtime")?;

    match command {
        UserCommand::Show(args) => runtime.block_on(handle_user_show(args, config)),
        UserCommand::Search(args) => runtime.block_on(handle_user_search(args, config)),
        UserCommand::Me(args) => runtime.block_on(handle_user_me(args, config)),
    }
}

async fn handle_user_show(args: UserShowArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;

    let user = if args.user == "me" {
        api::get_current_user(&client).await
    } else {
        api::get_user(&client, &args.user).await
    }
    .context("failed to get user")?;

    match args.format {
        OutputFormat::Detail | OutputFormat::Table => render_user_detail(&user),
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&user)?;
            println!("{json}");
        }
    }

    Ok(())
}

async fn handle_user_search(args: UserSearchArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;

    let workspace = args
        .workspace
        .or_else(|| config.default_workspace().map(String::from))
        .ok_or_else(|| anyhow!("workspace is required; provide --workspace or set a default"))?;

    let params = UserSearchParams {
        workspace,
        query: args.query,
        limit: args.limit,
    };

    let users = api::search_users(&client, params)
        .await
        .context("failed to search users")?;

    match args.format {
        OutputFormat::Table => render_user_table(&users),
        OutputFormat::Detail => {
            for user in &users {
                render_user_detail(user);
                println!();
            }
        }
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&users)?;
            println!("{json}");
        }
    }

    Ok(())
}

async fn handle_user_me(args: UserMeArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;
    let user = api::get_current_user(&client)
        .await
        .context("failed to get current user")?;

    match args.format {
        OutputFormat::Detail | OutputFormat::Table => render_user_detail(&user),
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&user)?;
            println!("{json}");
        }
    }

    Ok(())
}

fn render_user_table(users: &[User]) {
    if users.is_empty() {
        println!("No users found.");
        return;
    }

    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{:<20} {:<30} {}", "GID".bold(), "Name".bold(), "Email".bold());
        println!("{}", "─".repeat(70));
    }

    for user in users {
        let email = user.email.as_deref().unwrap_or("(no email)");
        if is_tty {
            println!("{:<20} {:<30} {}", user.gid, user.name, email);
        } else {
            println!("{}\t{}\t{}", user.gid, user.name, email);
        }
    }

    if is_tty {
        println!("\n{} users found.", users.len());
    }
}

fn render_user_detail(user: &User) {
    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{}", "User Details".bold().underline());
        println!("  {}: {}", "GID".bold(), user.gid);
        println!("  {}: {}", "Name".bold(), user.name);
        if let Some(email) = &user.email {
            println!("  {}: {}", "Email".bold(), email);
        }
        if !user.workspaces.is_empty() {
            println!("  {}:", "Workspaces".bold());
            for ws in &user.workspaces {
                println!("    - {} ({})", ws.label(), ws.gid);
            }
        }
    } else {
        println!("GID: {}", user.gid);
        println!("Name: {}", user.name);
        if let Some(email) = &user.email {
            println!("Email: {}", email);
        }
    }
}
```

## File Changes Summary

### New Files
- `src/api/workspaces.rs` (~50 lines)
- `src/api/users.rs` (~100 lines)
- `src/cli/workspace.rs` (~250 lines)
- `src/cli/user.rs` (~200 lines)

### Modified Files
- `src/models/workspace.rs` - Add Workspace struct and params (~50 lines added)
- `src/models/user.rs` - Add User, UserPhoto structs and params (~80 lines added)
- `src/models/mod.rs` - Export new types
- `src/api/mod.rs` - Export new modules and functions
- `src/cli/mod.rs` - Add Workspace and User commands

## Testing Strategy

### Unit Tests
- User search filtering logic
- Model serialization/deserialization

### Integration Tests
- List workspaces with pagination
- Get workspace details
- List users in workspace
- Search users by name/email
- Get current user
- Get specific user
- Error handling (404, network errors)

### Manual Testing Checklist
- [ ] List all workspaces
- [ ] Show workspace details
- [ ] List users in workspace
- [ ] Search users by name
- [ ] Search users by email
- [ ] Show current user (me)
- [ ] Show specific user by GID
- [ ] Test with non-existent workspace/user (404)
- [ ] Test output formats (table, json, detail)
- [ ] Test with workspace from config default

## Example Usage

```bash
# List workspaces
asana-cli workspace list

# Show workspace details
asana-cli workspace show 1234567890

# List users in workspace
asana-cli workspace users 1234567890

# Show current user
asana-cli user me

# Show specific user
asana-cli user show 9876543210

# Search for users
asana-cli user search --query "Sarah" --workspace 1234567890

# Search by email
asana-cli user search --query "@example.com" --workspace 1234567890

# JSON output
asana-cli workspace list --format json
```

## Success Criteria

- [ ] All models implemented
- [ ] All API operations functional
- [ ] CLI commands with help text
- [ ] Unit tests at 80%+ coverage
- [ ] Integration tests pass
- [ ] Clippy pedantic passes
- [ ] Manual testing complete
- [ ] README updated with examples

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| User search slow on large workspaces | Medium | Medium | Fetch all users, filter client-side, document limitation |
| No direct user search API | Low | Certain | Client-side filtering acceptable for typical workspaces |
| Photo URLs may be broken/expired | Low | Low | Handle gracefully, don't display photos in CLI |

## Future Enhancements

- User task lists
- User favorites
- Team memberships for user
- Workspace memberships API
- User presence/status
