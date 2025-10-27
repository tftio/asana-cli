# Phase 6: Teams

**Priority**: LOWER
**Status**: 📋 Planned
**Estimated Effort**: 4-5 hours
**Dependencies**: Phase 2 (workspace/user operations)

## Overview

Implement team discovery and member listing. Teams are organizational units within workspaces that group related projects and people together.

**User Value**: "Which teams am I a member of?" or "Who else is on the Marketing team?"

## Scope

### In Scope
- List teams in a workspace
- Get team details
- List team members
- Get user's teams

### Out of Scope
- Team creation/deletion (typically admin-only)
- Team settings management (admin-only)
- Add/remove team members (admin-only)
- Team permissions configuration

## Asana API Endpoints

| Method | Endpoint | Purpose | Scope Required |
|--------|----------|---------|----------------|
| GET | `/organizations/{workspace_gid}/teams` | List teams in organization | default |
| GET | `/teams/{team_gid}` | Get team details | default |
| GET | `/teams/{team_gid}/users` | List team members | default |
| GET | `/users/{user_gid}/teams` | Get user's teams | default |

## Data Models

### File: `src/models/team.rs` (new)

```rust
//! Team data structures.

use super::{user::UserReference, workspace::WorkspaceReference};
use serde::{Deserialize, Serialize};

/// Compact team reference.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Ord, PartialOrd)]
#[serde(rename_all = "camelCase")]
pub struct TeamCompact {
    /// Globally unique identifier.
    pub gid: String,
    /// Team name.
    pub name: String,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
}

impl TeamCompact {
    /// Human readable label.
    #[must_use]
    pub fn label(&self) -> &str {
        &self.name
    }
}

/// Team visibility setting.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum TeamVisibility {
    /// Public to organization.
    Public,
    /// Request to join.
    RequestToJoin,
    /// Secret/private team.
    Secret,
}

/// Full team payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Team {
    /// Globally unique identifier.
    pub gid: String,
    /// Team name.
    pub name: String,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Team description.
    #[serde(default)]
    pub description: Option<String>,
    /// HTML formatted description.
    #[serde(default)]
    pub html_description: Option<String>,
    /// Organization/workspace the team belongs to.
    #[serde(default)]
    pub organization: Option<WorkspaceReference>,
    /// Team visibility.
    #[serde(default)]
    pub visibility: Option<TeamVisibility>,
    /// Public permalink.
    #[serde(default)]
    pub permalink_url: Option<String>,
}

/// Parameters for listing teams.
#[derive(Debug, Clone)]
pub struct TeamListParams {
    /// Organization/workspace identifier (required).
    pub organization: String,
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}

impl TeamListParams {
    #[must_use]
    pub fn to_query(&self) -> Vec<(String, String)> {
        vec![]
    }
}

/// Parameters for listing team members.
#[derive(Debug, Clone)]
pub struct TeamMemberListParams {
    /// Team identifier.
    pub team_gid: String,
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}
```

## API Operations

### File: `src/api/teams.rs` (new)

```rust
//! High level team operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{Team, TeamListParams, TeamMemberListParams, User},
};
use futures_util::{pin_mut, StreamExt};
use serde::Deserialize;

/// List teams in an organization.
pub async fn list_teams(
    client: &ApiClient,
    params: TeamListParams,
) -> Result<Vec<Team>, ApiError> {
    let endpoint = format!("/organizations/{}/teams", params.organization);
    let query = params.to_query();
    let stream = client.paginate_with_limit::<Team>(&endpoint, query, params.limit);
    pin_mut!(stream);

    let mut teams = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        teams.append(&mut page);
    }

    Ok(teams)
}

/// Get a single team.
pub async fn get_team(client: &ApiClient, gid: &str) -> Result<Team, ApiError> {
    let response: SingleTeamResponse = client
        .get_json_with_pairs(&format!("/teams/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

/// List members of a team.
pub async fn list_team_members(
    client: &ApiClient,
    params: TeamMemberListParams,
) -> Result<Vec<User>, ApiError> {
    let endpoint = format!("/teams/{}/users", params.team_gid);
    let stream = client.paginate_with_limit::<User>(&endpoint, vec![], params.limit);
    pin_mut!(stream);

    let mut users = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        users.append(&mut page);
    }

    Ok(users)
}

/// Get teams for a user.
pub async fn get_user_teams(
    client: &ApiClient,
    user_gid: &str,
    organization: &str,
) -> Result<Vec<Team>, ApiError> {
    let endpoint = format!("/users/{}/teams", user_gid);
    let query = vec![("organization".into(), organization.to_string())];
    let stream = client.paginate_with_limit::<Team>(&endpoint, query, None);
    pin_mut!(stream);

    let mut teams = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        teams.append(&mut page);
    }

    Ok(teams)
}

#[derive(Debug, Deserialize)]
struct SingleTeamResponse {
    data: Team,
}
```

## CLI Commands

### File: `src/cli/team.rs` (new)

```rust
//! Team CLI command implementations.

use super::build_api_client;
use crate::{
    api,
    config::Config,
    error::Result,
    models::{Team, TeamListParams, TeamMemberListParams, User},
};
use anyhow::{Context, anyhow};
use clap::{Args, Subcommand, ValueEnum};
use colored::Colorize;
use std::io::{IsTerminal, stdout};
use tokio::runtime::Builder as RuntimeBuilder;

#[derive(Subcommand, Debug)]
pub enum TeamCommand {
    /// List teams in an organization.
    List(TeamListArgs),
    /// Show team details.
    Show(TeamShowArgs),
    /// List team members.
    Members(TeamMembersArgs),
}

#[derive(Args, Debug)]
pub struct TeamListArgs {
    /// Organization/workspace identifier.
    #[arg(long)]
    pub organization: Option<String>,
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum, default_value = "table")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct TeamShowArgs {
    /// Team identifier.
    #[arg(value_name = "TEAM")]
    pub team: String,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct TeamMembersArgs {
    /// Team identifier.
    #[arg(value_name = "TEAM")]
    pub team: String,
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

pub fn handle_team_command(command: TeamCommand, config: &Config) -> Result<()> {
    let runtime = RuntimeBuilder::new_current_thread()
        .enable_all()
        .build()
        .context("failed to initialise async runtime")?;

    match command {
        TeamCommand::List(args) => runtime.block_on(handle_team_list(args, config)),
        TeamCommand::Show(args) => runtime.block_on(handle_team_show(args, config)),
        TeamCommand::Members(args) => runtime.block_on(handle_team_members(args, config)),
    }
}

async fn handle_team_list(args: TeamListArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;

    let organization = args
        .organization
        .or_else(|| config.default_workspace().map(String::from))
        .ok_or_else(|| anyhow!("organization is required; provide --organization or set a default workspace"))?;

    let params = TeamListParams {
        organization,
        limit: args.limit,
    };

    let teams = api::list_teams(&client, params)
        .await
        .context("failed to list teams")?;

    match args.format {
        OutputFormat::Table => render_team_table(&teams),
        OutputFormat::Detail => {
            for team in &teams {
                render_team_detail(team);
                println!();
            }
        }
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&teams)?;
            println!("{json}");
        }
    }

    Ok(())
}

async fn handle_team_show(args: TeamShowArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;

    let team = api::get_team(&client, &args.team)
        .await
        .context("failed to get team")?;

    match args.format {
        OutputFormat::Detail | OutputFormat::Table => render_team_detail(&team),
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&team)?;
            println!("{json}");
        }
    }

    Ok(())
}

async fn handle_team_members(args: TeamMembersArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;

    let params = TeamMemberListParams {
        team_gid: args.team,
        limit: args.limit,
    };

    let users = api::list_team_members(&client, params)
        .await
        .context("failed to list team members")?;

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

fn render_team_table(teams: &[Team]) {
    if teams.is_empty() {
        println!("No teams found.");
        return;
    }

    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{:<20} {:<40} {}", "GID".bold(), "Name".bold(), "Visibility".bold());
        println!("{}", "─".repeat(70));
    }

    for team in teams {
        let visibility = team
            .visibility
            .map(format_visibility)
            .unwrap_or_else(|| String::from("unknown"));

        if is_tty {
            println!("{:<20} {:<40} {}", team.gid, team.name, visibility);
        } else {
            println!("{}\t{}\t{}", team.gid, team.name, visibility);
        }
    }

    if is_tty {
        println!("\n{} teams listed.", teams.len());
    }
}

fn render_team_detail(team: &Team) {
    let is_tty = stdout().is_terminal();

    if is_tty {
        println!("{}", "Team Details".bold().underline());
        println!("  {}: {}", "GID".bold(), team.gid);
        println!("  {}: {}", "Name".bold(), team.name);

        if let Some(description) = &team.description {
            if !description.is_empty() {
                println!("  {}: {}", "Description".bold(), description);
            }
        }

        if let Some(visibility) = &team.visibility {
            println!("  {}: {}", "Visibility".bold(), format_visibility(*visibility));
        }

        if let Some(org) = &team.organization {
            println!("  {}: {} ({})", "Organization".bold(), org.label(), org.gid);
        }

        if let Some(url) = &team.permalink_url {
            println!("  {}: {}", "URL".bold(), url);
        }
    } else {
        println!("GID: {}", team.gid);
        println!("Name: {}", team.name);

        if let Some(description) = &team.description {
            if !description.is_empty() {
                println!("Description: {}", description);
            }
        }

        if let Some(visibility) = &team.visibility {
            println!("Visibility: {}", format_visibility(*visibility));
        }
    }
}

fn format_visibility(visibility: TeamVisibility) -> String {
    match visibility {
        TeamVisibility::Public => "public".to_string(),
        TeamVisibility::RequestToJoin => "request_to_join".to_string(),
        TeamVisibility::Secret => "secret".to_string(),
    }
}

fn render_user_table(users: &[User]) {
    // Reuse user rendering from Phase 2
    if users.is_empty() {
        println!("No members found.");
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
        println!("\n{} members listed.", users.len());
    }
}

fn render_user_detail(user: &User) {
    // Same as Phase 2 user detail rendering
    let is_tty = stdout().is_terminal();
    if is_tty {
        println!("{}", "User Details".bold().underline());
        println!("  {}: {}", "GID".bold(), user.gid);
        println!("  {}: {}", "Name".bold(), user.name);
        if let Some(email) = &user.email {
            println!("  {}: {}", "Email".bold(), email);
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
- `src/models/team.rs` (~120 lines)
- `src/api/teams.rs` (~100 lines)
- `src/cli/team.rs` (~280 lines)

### Modified Files
- `src/models/mod.rs` - Export team models
- `src/api/mod.rs` - Export teams module
- `src/cli/mod.rs` - Add Team command variant and handler

## Testing Strategy

### Unit Tests
- TeamVisibility serialization
- Model serialization/deserialization

### Integration Tests
- List teams in organization
- Get team details
- List team members
- Get user's teams
- Error handling (404, invalid workspace)

### Manual Testing Checklist
- [ ] List teams in workspace
- [ ] Show team details
- [ ] List team members
- [ ] Test with organization (not workspace)
- [ ] Test with non-existent team (404)
- [ ] Test output formats (table, json, detail)
- [ ] Verify default workspace from config

## Example Usage

```bash
# List teams in organization
asana-cli team list --organization 1234567890

# Show team details
asana-cli team show 9876543210

# List team members
asana-cli team members 9876543210

# Use default workspace from config
asana-cli config set workspace --workspace 1234567890
asana-cli team list

# JSON output
asana-cli team list --organization 1234567890 --format json
```

## Success Criteria

- [ ] All team models implemented
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
| Workspaces vs Organizations confusion | Medium | Medium | Clear documentation, check is_organization flag |
| Team permissions not exposed | Low | Certain | Document read-only access, focus on discovery |
| Limited team management | Low | Certain | Document that admin operations not supported |

## Notes on Workspaces vs Organizations

### Key Differences
- **Workspace**: Can be personal or organizational
- **Organization**: Enterprise workspace with teams, domains, admin controls
- **Team Endpoint**: Requires organization, not workspace

### API Behavior
- `/organizations/{workspace_gid}/teams` works if workspace is organization
- If workspace is NOT organization, API returns 400 or empty list
- Need to check `workspace.is_organization` flag

### CLI Handling
```rust
async fn handle_team_list(args: TeamListArgs, config: &Config) -> Result<()> {
    let organization = args.organization
        .or_else(|| config.default_workspace().map(String::from))
        .ok_or_else(|| anyhow!("organization required"))?;

    // Optionally verify it's an organization
    let workspace = api::get_workspace(&client, &organization).await?;
    if !workspace.is_organization {
        eprintln!("{}", "Warning: Workspace is not an organization. Teams may not be available.".yellow());
    }

    // Proceed with team listing...
}
```

## Future Enhancements

- Team creation/deletion (admin operations)
- Add/remove team members (admin operations)
- Team settings management
- Team projects listing
- Team task lists
- My teams shortcut (`team list --me`)
