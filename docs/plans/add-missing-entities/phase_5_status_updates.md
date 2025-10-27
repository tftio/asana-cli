# Phase 5: Status Updates

**Priority**: MEDIUM
**Status**: 📋 Planned
**Estimated Effort**: 4-5 hours
**Dependencies**: None

## Overview

Implement project status update functionality. Status updates are progress reports that communicate project health to stakeholders using structured status types (on_track, at_risk, etc.).

**User Value**: "I need to post a weekly project update showing we're on track" or "Mark this project as at risk due to resource constraints"

## Scope

### In Scope
- List status updates for a project/portfolio/goal
- Create status update on a project
- Get specific status update details
- Delete status update

### Out of Scope
- Update existing status (API doesn't support PUT on status updates)
- Status update reactions/likes (future enhancement)
- Portfolio status updates (Phase 7 - Premium)
- Goal status updates (Phase 7 - Premium)

## Asana API Endpoints

| Method | Endpoint | Purpose | Scope Required |
|--------|----------|---------|----------------|
| GET | `/status_updates` | List status updates (with filters) | default |
| POST | `/status_updates` | Create status update | default |
| GET | `/status_updates/{status_update_gid}` | Get single status | default |
| DELETE | `/status_updates/{status_update_gid}` | Delete status | default |

### Query Parameters for List
- `parent` - Parent resource GID (project/portfolio/goal)
- `created_since` - Filter by creation date
- `opt_fields` - Fields to include

## Data Models

### File: `src/models/status_update.rs` (new)

```rust
//! Status update data structures for project progress reporting.

use super::user::UserReference;
use serde::{Deserialize, Serialize};
use std::ops::Deref;
use thiserror::Error;

/// Status update type classification.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum StatusType {
    /// On track.
    OnTrack,
    /// At risk.
    AtRisk,
    /// Off track.
    OffTrack,
    /// On hold.
    OnHold,
    /// Complete.
    Complete,
    /// Achieved (for goals).
    Achieved,
    /// Partial (for goals).
    Partial,
    /// Dropped (for goals).
    Dropped,
    /// Missed (for goals).
    Missed,
}

/// Status update resource subtype.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum StatusUpdateSubtype {
    /// Project status update.
    ProjectStatusUpdate,
    /// Portfolio status update.
    PortfolioStatusUpdate,
    /// Goal status update.
    GoalStatusUpdate,
}

/// Compact status update reference.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct StatusUpdateCompact {
    /// Globally unique identifier.
    pub gid: String,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Status update title.
    #[serde(default)]
    pub title: Option<String>,
}

/// Full status update payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct StatusUpdate {
    /// Globally unique identifier.
    pub gid: String,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Resource subtype.
    #[serde(default)]
    pub resource_subtype: Option<StatusUpdateSubtype>,
    /// Status update title.
    #[serde(default)]
    pub title: Option<String>,
    /// Plain text content.
    #[serde(default)]
    pub text: Option<String>,
    /// HTML formatted content.
    #[serde(default)]
    pub html_text: Option<String>,
    /// Status type.
    pub status_type: StatusType,
    /// Author.
    #[serde(default)]
    pub author: Option<UserReference>,
    /// Creator.
    #[serde(default)]
    pub created_by: Option<UserReference>,
    /// Creation timestamp.
    #[serde(default)]
    pub created_at: Option<String>,
    /// Modification timestamp.
    #[serde(default)]
    pub modified_at: Option<String>,
}

/// Parameters for listing status updates.
#[derive(Debug, Clone)]
pub struct StatusUpdateListParams {
    /// Parent resource (project/portfolio/goal).
    pub parent: String,
    /// Created since timestamp.
    pub created_since: Option<String>,
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}

impl StatusUpdateListParams {
    #[must_use]
    pub fn to_query(&self) -> Vec<(String, String)> {
        let mut pairs = vec![("parent".into(), self.parent.clone())];
        if let Some(since) = &self.created_since {
            pairs.push(("created_since".into(), since.clone()));
        }
        pairs
    }
}

/// Payload for creating status updates.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct StatusUpdateCreateData {
    /// Parent resource (project/portfolio/goal).
    pub parent: String,
    /// Status type (required).
    pub status_type: StatusType,
    /// Optional title.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub title: Option<String>,
    /// Plain text content.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub text: Option<String>,
    /// HTML formatted content.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub html_text: Option<String>,
}

/// API envelope for create requests.
#[derive(Debug, Clone, Serialize)]
pub struct StatusUpdateCreateRequest {
    pub data: StatusUpdateCreateData,
}

/// Builder for status update create payloads.
#[derive(Debug, Clone)]
pub struct StatusUpdateCreateBuilder {
    data: StatusUpdateCreateData,
}

impl StatusUpdateCreateBuilder {
    /// Create builder with required fields.
    #[must_use]
    pub fn new(parent: impl Into<String>, status_type: StatusType) -> Self {
        Self {
            data: StatusUpdateCreateData {
                parent: parent.into(),
                status_type,
                title: None,
                text: None,
                html_text: None,
            },
        }
    }

    /// Set the title.
    #[must_use]
    pub fn title(mut self, title: impl Into<String>) -> Self {
        self.data.title = Some(title.into());
        self
    }

    /// Set plain text content.
    #[must_use]
    pub fn text(mut self, text: impl Into<String>) -> Self {
        self.data.text = Some(text.into());
        self
    }

    /// Set HTML formatted content.
    #[must_use]
    pub fn html_text(mut self, html: impl Into<String>) -> Self {
        self.data.html_text = Some(html.into());
        self
    }

    /// Build the request.
    pub fn build(self) -> Result<StatusUpdateCreateRequest, StatusUpdateValidationError> {
        if self.data.parent.trim().is_empty() {
            return Err(StatusUpdateValidationError::MissingParent);
        }
        Ok(StatusUpdateCreateRequest { data: self.data })
    }
}

/// Validation errors for status updates.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum StatusUpdateValidationError {
    #[error("status update requires a parent resource")]
    MissingParent,
}

impl Deref for StatusUpdateCreateBuilder {
    type Target = StatusUpdateCreateData;
    fn deref(&self) -> &Self::Target {
        &self.data
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn create_builder_success() {
        let request = StatusUpdateCreateBuilder::new("proj-123", StatusType::OnTrack)
            .title("Week 42 Update")
            .text("Great progress this week!")
            .build()
            .unwrap();
        assert_eq!(request.data.status_type, StatusType::OnTrack);
        assert_eq!(request.data.title.as_deref(), Some("Week 42 Update"));
    }

    #[test]
    fn create_builder_requires_parent() {
        let builder = StatusUpdateCreateBuilder::new("  ", StatusType::OnTrack);
        assert_eq!(
            builder.build().unwrap_err(),
            StatusUpdateValidationError::MissingParent
        );
    }
}
```

## API Operations

### File: `src/api/status_updates.rs` (new)

```rust
//! High level status update operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{StatusUpdate, StatusUpdateCreateRequest, StatusUpdateListParams},
};
use futures_util::{pin_mut, StreamExt};
use serde::Deserialize;

/// List status updates for a parent resource.
pub async fn list_status_updates(
    client: &ApiClient,
    params: StatusUpdateListParams,
) -> Result<Vec<StatusUpdate>, ApiError> {
    let query = params.to_query();
    let stream = client.paginate_with_limit::<StatusUpdate>("/status_updates", query, params.limit);
    pin_mut!(stream);

    let mut updates = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        updates.append(&mut page);
    }

    Ok(updates)
}

/// Get a single status update.
pub async fn get_status_update(client: &ApiClient, gid: &str) -> Result<StatusUpdate, ApiError> {
    let response: SingleStatusUpdateResponse = client
        .get_json_with_pairs(&format!("/status_updates/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

/// Create a status update.
pub async fn create_status_update(
    client: &ApiClient,
    request: StatusUpdateCreateRequest,
) -> Result<StatusUpdate, ApiError> {
    let response: SingleStatusUpdateResponse = client.post_json("/status_updates", &request).await?;
    Ok(response.data)
}

/// Delete a status update.
pub async fn delete_status_update(client: &ApiClient, gid: &str) -> Result<(), ApiError> {
    client.delete(&format!("/status_updates/{gid}"), Vec::new()).await
}

#[derive(Debug, Deserialize)]
struct SingleStatusUpdateResponse {
    data: StatusUpdate,
}
```

## CLI Commands

### Extend: `src/cli/project.rs`

Add to `ProjectCommand` enum:
```rust
/// Manage project status updates.
Status {
    #[command(subcommand)]
    command: ProjectStatusCommand,
},
```

Add new subcommand enum:
```rust
#[derive(Subcommand, Debug)]
pub enum ProjectStatusCommand {
    /// List status updates for a project.
    List(ProjectStatusListArgs),
    /// Show a specific status update.
    Show(ProjectStatusShowArgs),
    /// Create a status update.
    Create(ProjectStatusCreateArgs),
    /// Delete a status update.
    Delete(ProjectStatusDeleteArgs),
}

#[derive(Args, Debug)]
pub struct ProjectStatusListArgs {
    /// Project identifier.
    #[arg(value_name = "PROJECT")]
    pub project: String,
    /// Created since date (YYYY-MM-DD).
    #[arg(long)]
    pub since: Option<String>,
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum, default_value = "table")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct ProjectStatusShowArgs {
    /// Status update identifier.
    #[arg(value_name = "STATUS")]
    pub status: String,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct ProjectStatusCreateArgs {
    /// Project identifier.
    #[arg(value_name = "PROJECT")]
    pub project: String,
    /// Status type.
    #[arg(long, value_enum)]
    pub status: StatusTypeArg,
    /// Optional title.
    #[arg(long)]
    pub title: Option<String>,
    /// Status update text.
    #[arg(long)]
    pub text: Option<String>,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: OutputFormat,
}

#[derive(Args, Debug)]
pub struct ProjectStatusDeleteArgs {
    /// Status update identifier.
    #[arg(value_name = "STATUS")]
    pub status: String,
    /// Skip confirmation.
    #[arg(long)]
    pub yes: bool,
}

#[derive(Debug, Clone, Copy, ValueEnum)]
#[value(rename_all = "kebab-case")]
pub enum StatusTypeArg {
    OnTrack,
    AtRisk,
    OffTrack,
    OnHold,
    Complete,
}

impl From<StatusTypeArg> for StatusType {
    fn from(arg: StatusTypeArg) -> Self {
        match arg {
            StatusTypeArg::OnTrack => Self::OnTrack,
            StatusTypeArg::AtRisk => Self::AtRisk,
            StatusTypeArg::OffTrack => Self::OffTrack,
            StatusTypeArg::OnHold => Self::OnHold,
            StatusTypeArg::Complete => Self::Complete,
        }
    }
}
```

Rendering functions:
```rust
fn render_status_update_table(updates: &[StatusUpdate]) {
    if updates.is_empty() {
        println!("No status updates found.");
        return;
    }

    let is_tty = stdout().is_terminal();
    if is_tty {
        println!(
            "{:<20} {:<30} {:<15} {}",
            "GID".bold(),
            "Title".bold(),
            "Status".bold(),
            "Author".bold()
        );
        println!("{}", "─".repeat(80));
    }

    for update in updates {
        let title = update.title.as_deref().unwrap_or("(no title)");
        let status = format_status_type(update.status_type);
        let author = update
            .author
            .as_ref()
            .map(|u| u.label())
            .unwrap_or_else(|| String::from("unknown"));

        if is_tty {
            let colored_status = colorize_status(update.status_type, &status);
            println!("{:<20} {:<30} {:<15} {}", update.gid, title, colored_status, author);
        } else {
            println!("{}\t{}\t{}\t{}", update.gid, title, status, author);
        }
    }

    if is_tty {
        println!("\n{} status updates listed.", updates.len());
    }
}

fn render_status_update_detail(update: &StatusUpdate) {
    let is_tty = stdout().is_terminal();

    if is_tty {
        println!("{}", "Status Update Details".bold().underline());
        println!("  {}: {}", "GID".bold(), update.gid);

        if let Some(title) = &update.title {
            println!("  {}: {}", "Title".bold(), title);
        }

        let status = format_status_type(update.status_type);
        let colored_status = colorize_status(update.status_type, &status);
        println!("  {}: {}", "Status".bold(), colored_status);

        if let Some(text) = &update.text {
            if !text.is_empty() {
                println!("  {}: {}", "Text".bold(), text);
            }
        }

        if let Some(author) = &update.author {
            println!("  {}: {}", "Author".bold(), author.label());
        }

        if let Some(created_at) = &update.created_at {
            println!("  {}: {}", "Created".bold(), created_at);
        }
    } else {
        println!("GID: {}", update.gid);
        if let Some(title) = &update.title {
            println!("Title: {}", title);
        }
        println!("Status: {}", format_status_type(update.status_type));
        if let Some(text) = &update.text {
            if !text.is_empty() {
                println!("Text: {}", text);
            }
        }
    }
}

fn format_status_type(status: StatusType) -> String {
    match status {
        StatusType::OnTrack => "on_track".to_string(),
        StatusType::AtRisk => "at_risk".to_string(),
        StatusType::OffTrack => "off_track".to_string(),
        StatusType::OnHold => "on_hold".to_string(),
        StatusType::Complete => "complete".to_string(),
        StatusType::Achieved => "achieved".to_string(),
        StatusType::Partial => "partial".to_string(),
        StatusType::Dropped => "dropped".to_string(),
        StatusType::Missed => "missed".to_string(),
    }
}

fn colorize_status(status: StatusType, text: &str) -> colored::ColoredString {
    match status {
        StatusType::OnTrack | StatusType::Complete | StatusType::Achieved => text.green(),
        StatusType::AtRisk | StatusType::OnHold | StatusType::Partial => text.yellow(),
        StatusType::OffTrack | StatusType::Dropped | StatusType::Missed => text.red(),
    }
}
```

## File Changes Summary

### New Files
- `src/models/status_update.rs` (~250 lines)
- `src/api/status_updates.rs` (~80 lines)

### Modified Files
- `src/models/mod.rs` - Export status update models
- `src/api/mod.rs` - Export status_updates module
- `src/cli/project.rs` - Add Status subcommand (~250 lines)

## Testing Strategy

### Unit Tests
- StatusType serialization
- Builder validation
- Query parameter generation
- Status colorization logic

### Integration Tests
- List status updates for project
- Create status update
- Get status update details
- Delete status update
- Filter by created_since
- Pagination

### Manual Testing Checklist
- [ ] List status updates for project
- [ ] Create status update (on_track)
- [ ] Create status update (at_risk)
- [ ] Create status update with title and text
- [ ] Show specific status update
- [ ] Delete status update
- [ ] Test with project that has no statuses
- [ ] Test created_since filter
- [ ] Verify status color coding in terminal
- [ ] Test output formats (table, json, detail)

## Example Usage

```bash
# List status updates for a project
asana-cli project status list 1234567890

# Create status update
asana-cli project status create 1234567890 \
  --status on-track \
  --title "Week 42 Update" \
  --text "Completed API integration. On schedule for release."

# Create at-risk status
asana-cli project status create 1234567890 \
  --status at-risk \
  --title "Resource Constraint" \
  --text "Need additional developer for backend work."

# Show specific status update
asana-cli project status show 9876543210

# Delete status update
asana-cli project status delete 9876543210

# List recent updates (last 7 days)
asana-cli project status list 1234567890 --since 2025-10-19

# JSON output
asana-cli project status list 1234567890 --format json
```

## Success Criteria

- [ ] All status update models implemented
- [ ] All API operations functional
- [ ] CLI commands with help text
- [ ] Status color coding working
- [ ] Unit tests at 80%+ coverage
- [ ] Integration tests pass
- [ ] Clippy pedantic passes
- [ ] Manual testing complete
- [ ] README updated with examples

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| No UPDATE endpoint exists | Low | Certain | Document that updates cannot be edited, only deleted/recreated |
| Status types vary by parent | Medium | Low | Support all types, let API validate |
| HTML text formatting complex | Low | Low | Document plain text as primary, HTML as advanced |

## Notes on ProjectStatus vs StatusUpdate

### Current Implementation
- `ProjectStatus` exists in `src/models/project.rs` (lines 108-129)
- It's a simplified struct with: gid, title, color, text, created_at, created_by
- Used when fetching project.statuses field

### New Implementation
- `StatusUpdate` will be the full model with all fields
- `ProjectStatus` can remain for project details view
- May want to migrate ProjectStatus to use StatusUpdate eventually

## Future Enhancements

- Portfolio status updates (Premium)
- Goal status updates (Premium)
- Status update reactions/likes
- Rich text formatting support
- Status update templates
- Scheduled status updates
- Status update notifications
