# Phase 1: Stories (Task Comments)

**Priority**: HIGHEST
**Status**: 📋 Planned
**Estimated Effort**: 4-6 hours
**Dependencies**: None

## Overview

Implement task comment functionality (user-created stories only). This is the most frequently used feature for individual contributors who need to communicate about tasks, document decisions, and provide status updates.

**User Value**: "I need to leave a note on this task about the bug I found" or "I want to document the solution for future reference"

## Scope

### In Scope
- List comments on a task
- Create new comment on a task
- Get specific comment details
- Update existing comment (if authored by user)
- Delete comment (if authored by user)
- Pin/unpin comments

### Out of Scope
- System-generated activity stories (deferred)
- Story reactions/likes (future enhancement)
- Story attachments/previews (future enhancement)
- Stories on projects (focus on tasks only)

## Asana API Endpoints

| Method | Endpoint | Purpose | Scope Required |
|--------|----------|---------|----------------|
| GET | `/tasks/{task_gid}/stories` | List all stories on task | `stories:read` |
| POST | `/tasks/{task_gid}/stories` | Create comment story | `stories:write` |
| GET | `/stories/{story_gid}` | Get single story | `stories:read` |
| PUT | `/stories/{story_gid}` | Update story | `stories:write` |
| DELETE | `/stories/{story_gid}` | Delete story | `stories:write` |

## Data Models

### File: `src/models/story.rs`

```rust
//! Story (comment) data structures for task activity.

use super::user::UserReference;
use serde::{Deserialize, Serialize};
use std::ops::Deref;
use thiserror::Error;

/// Story type classification.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum StoryType {
    /// User-created comment.
    Comment,
    /// System-generated activity (not supported for creation).
    System,
}

/// Compact story reference.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct StoryCompact {
    /// Globally unique identifier.
    pub gid: String,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Story type.
    #[serde(rename = "type")]
    pub story_type: StoryType,
}

/// Full story payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Story {
    /// Globally unique identifier.
    pub gid: String,
    /// Resource type marker.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Story type.
    #[serde(rename = "type")]
    pub story_type: StoryType,
    /// Plain text content.
    #[serde(default)]
    pub text: Option<String>,
    /// HTML formatted content.
    #[serde(default)]
    pub html_text: Option<String>,
    /// Whether story is pinned.
    #[serde(default)]
    pub is_pinned: bool,
    /// Whether story can be edited by current user.
    #[serde(default)]
    pub is_editable: bool,
    /// Whether story has been edited.
    #[serde(default)]
    pub is_edited: bool,
    /// Story author.
    #[serde(default)]
    pub created_by: Option<UserReference>,
    /// Creation timestamp.
    #[serde(default)]
    pub created_at: Option<String>,
}

/// Parameters for listing stories.
#[derive(Debug, Clone, Default)]
pub struct StoryListParams {
    /// Task identifier.
    pub task_gid: String,
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}

/// Payload for creating stories.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct StoryCreateData {
    /// Plain text content (required, mutually exclusive with html_text).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub text: Option<String>,
    /// HTML formatted content (mutually exclusive with text).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub html_text: Option<String>,
    /// Whether to pin the comment.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub is_pinned: Option<bool>,
}

/// API envelope for create requests.
#[derive(Debug, Clone, Serialize)]
pub struct StoryCreateRequest {
    pub data: StoryCreateData,
}

/// Builder for story create payloads.
#[derive(Debug, Clone)]
pub struct StoryCreateBuilder {
    data: StoryCreateData,
}

impl StoryCreateBuilder {
    /// Create builder with plain text.
    #[must_use]
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            data: StoryCreateData {
                text: Some(text.into()),
                html_text: None,
                is_pinned: None,
            },
        }
    }

    /// Create builder with HTML text.
    #[must_use]
    pub fn with_html(html_text: impl Into<String>) -> Self {
        Self {
            data: StoryCreateData {
                text: None,
                html_text: Some(html_text.into()),
                is_pinned: None,
            },
        }
    }

    /// Set whether comment should be pinned.
    #[must_use]
    pub fn is_pinned(mut self, pinned: bool) -> Self {
        self.data.is_pinned = Some(pinned);
        self
    }

    /// Build the request.
    pub fn build(self) -> Result<StoryCreateRequest, StoryValidationError> {
        if self.data.text.is_none() && self.data.html_text.is_none() {
            return Err(StoryValidationError::MissingText);
        }
        if self.data.text.is_some() && self.data.html_text.is_some() {
            return Err(StoryValidationError::BothTextFormats);
        }
        Ok(StoryCreateRequest { data: self.data })
    }
}

/// Payload for updating stories.
#[derive(Debug, Clone, Serialize, Default, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct StoryUpdateData {
    /// Updated plain text.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub text: Option<String>,
    /// Updated HTML text.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub html_text: Option<String>,
    /// Updated pin status.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub is_pinned: Option<bool>,
}

/// API envelope for update requests.
#[derive(Debug, Clone, Serialize)]
pub struct StoryUpdateRequest {
    pub data: StoryUpdateData,
}

/// Builder for story update payloads.
#[derive(Debug, Clone, Default)]
pub struct StoryUpdateBuilder {
    data: StoryUpdateData,
}

impl StoryUpdateBuilder {
    #[must_use]
    pub fn new() -> Self {
        Self::default()
    }

    #[must_use]
    pub fn text(mut self, text: impl Into<String>) -> Self {
        self.data.text = Some(text.into());
        self
    }

    #[must_use]
    pub fn html_text(mut self, html: impl Into<String>) -> Self {
        self.data.html_text = Some(html.into());
        self
    }

    #[must_use]
    pub fn is_pinned(mut self, pinned: bool) -> Self {
        self.data.is_pinned = Some(pinned);
        self
    }

    pub fn build(self) -> Result<StoryUpdateRequest, StoryValidationError> {
        if self.data.text.is_none()
            && self.data.html_text.is_none()
            && self.data.is_pinned.is_none()
        {
            return Err(StoryValidationError::EmptyUpdate);
        }
        Ok(StoryUpdateRequest { data: self.data })
    }
}

/// Validation errors for story payloads.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum StoryValidationError {
    #[error("story must have either text or html_text")]
    MissingText,
    #[error("story cannot have both text and html_text")]
    BothTextFormats,
    #[error("story update must change at least one field")]
    EmptyUpdate,
}

impl Deref for StoryUpdateBuilder {
    type Target = StoryUpdateData;
    fn deref(&self) -> &Self::Target {
        &self.data
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn create_builder_requires_text() {
        let builder = StoryCreateBuilder {
            data: StoryCreateData {
                text: None,
                html_text: None,
                is_pinned: None,
            },
        };
        assert_eq!(
            builder.build().unwrap_err(),
            StoryValidationError::MissingText
        );
    }

    #[test]
    fn create_builder_rejects_both_formats() {
        let builder = StoryCreateBuilder {
            data: StoryCreateData {
                text: Some("plain".into()),
                html_text: Some("<b>html</b>".into()),
                is_pinned: None,
            },
        };
        assert_eq!(
            builder.build().unwrap_err(),
            StoryValidationError::BothTextFormats
        );
    }

    #[test]
    fn create_builder_success() {
        let request = StoryCreateBuilder::new("This is a comment")
            .is_pinned(true)
            .build()
            .unwrap();
        assert_eq!(request.data.text.as_deref(), Some("This is a comment"));
        assert_eq!(request.data.is_pinned, Some(true));
    }

    #[test]
    fn update_builder_requires_changes() {
        let builder = StoryUpdateBuilder::new();
        assert_eq!(
            builder.build().unwrap_err(),
            StoryValidationError::EmptyUpdate
        );
    }
}
```

## API Operations

### File: `src/api/stories.rs`

```rust
//! High level story (comment) operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{Story, StoryCreateRequest, StoryListParams, StoryUpdateRequest},
};
use futures_util::{pin_mut, StreamExt};
use serde::Deserialize;

/// List stories for a task.
pub async fn list_stories(
    client: &ApiClient,
    params: StoryListParams,
) -> Result<Vec<Story>, ApiError> {
    let endpoint = format!("/tasks/{}/stories", params.task_gid);
    let stream = client.paginate_with_limit::<Story>(&endpoint, vec![], params.limit);
    pin_mut!(stream);

    let mut stories = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        stories.append(&mut page);
    }

    Ok(stories)
}

/// Get a single story.
pub async fn get_story(client: &ApiClient, gid: &str) -> Result<Story, ApiError> {
    let response: SingleStoryResponse = client
        .get_json_with_pairs(&format!("/stories/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

/// Create a story (comment) on a task.
pub async fn create_story(
    client: &ApiClient,
    task_gid: &str,
    request: StoryCreateRequest,
) -> Result<Story, ApiError> {
    let response: SingleStoryResponse = client
        .post_json(&format!("/tasks/{task_gid}/stories"), &request)
        .await?;
    Ok(response.data)
}

/// Update a story.
pub async fn update_story(
    client: &ApiClient,
    gid: &str,
    request: StoryUpdateRequest,
) -> Result<Story, ApiError> {
    let response: SingleStoryResponse = client.put_json(&format!("/stories/{gid}"), &request).await?;
    Ok(response.data)
}

/// Delete a story.
pub async fn delete_story(client: &ApiClient, gid: &str) -> Result<(), ApiError> {
    client.delete(&format!("/stories/{gid}"), Vec::new()).await
}

#[derive(Debug, Deserialize)]
struct SingleStoryResponse {
    data: Story,
}
```

## CLI Commands

### Extend: `src/cli/task.rs`

Add to `TaskCommand` enum:
```rust
/// Manage task comments (stories).
Comments {
    #[command(subcommand)]
    command: TaskCommentsCommand,
},
```

Add new subcommand enum:
```rust
#[derive(Subcommand, Debug)]
pub enum TaskCommentsCommand {
    /// List comments on a task.
    List(TaskCommentsListArgs),
    /// Add a comment to a task.
    Add(TaskCommentsAddArgs),
    /// Show a specific comment.
    Show(TaskCommentsShowArgs),
    /// Update a comment.
    Update(TaskCommentsUpdateArgs),
    /// Delete a comment.
    Delete(TaskCommentsDeleteArgs),
}

#[derive(Args, Debug)]
pub struct TaskCommentsListArgs {
    /// Task identifier.
    #[arg(value_name = "TASK")]
    pub task: String,
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum, default_value = "table")]
    pub format: TaskOutputFormat,
}

#[derive(Args, Debug)]
pub struct TaskCommentsAddArgs {
    /// Task identifier.
    #[arg(value_name = "TASK")]
    pub task: String,
    /// Comment text.
    #[arg(long)]
    pub text: String,
    /// Pin the comment.
    #[arg(long)]
    pub pin: bool,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: TaskOutputFormat,
}

#[derive(Args, Debug)]
pub struct TaskCommentsShowArgs {
    /// Comment identifier.
    #[arg(value_name = "COMMENT")]
    pub comment: String,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: TaskOutputFormat,
}

#[derive(Args, Debug)]
pub struct TaskCommentsUpdateArgs {
    /// Comment identifier.
    #[arg(value_name = "COMMENT")]
    pub comment: String,
    /// Updated text.
    #[arg(long)]
    pub text: Option<String>,
    /// Pin the comment.
    #[arg(long)]
    pub pin: bool,
    /// Unpin the comment.
    #[arg(long)]
    pub unpin: bool,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: TaskOutputFormat,
}

#[derive(Args, Debug)]
pub struct TaskCommentsDeleteArgs {
    /// Comment identifier.
    #[arg(value_name = "COMMENT")]
    pub comment: String,
    /// Skip confirmation.
    #[arg(long)]
    pub yes: bool,
}
```

## File Changes Summary

### New Files
- `src/models/story.rs` (~350 lines)
- `src/api/stories.rs` (~100 lines)

### Modified Files
- `src/models/mod.rs` - Add `pub mod story;` and exports
- `src/api/mod.rs` - Add `pub mod stories;` and exports
- `src/cli/task.rs` - Add Comments subcommand (~200 lines)

## Testing Strategy

### Unit Tests
- `src/models/story.rs`:
  - Builder validation (missing text, both formats, empty update)
  - Builder success paths
  - Serialization/deserialization

### Integration Tests
- Mock API responses for all endpoints
- Error handling (404, 403, network errors)
- Pagination for story lists

### Manual Testing Checklist
- [ ] List comments on a task
- [ ] Add a comment to a task
- [ ] Show a specific comment
- [ ] Update your own comment
- [ ] Delete your own comment
- [ ] Try to update someone else's comment (should fail)
- [ ] Pin/unpin a comment
- [ ] Test with empty task (no comments)
- [ ] Test pagination with many comments
- [ ] Test output formats (table, json, detail)

## Example Usage

```bash
# List comments on a task
asana-cli task comments list 1234567890

# Add a comment
asana-cli task comments add 1234567890 --text "Fixed the bug in the API handler"

# Pin a comment
asana-cli task comments add 1234567890 --text "IMPORTANT: Read before starting" --pin

# Update a comment
asana-cli task comments update 9876543210 --text "Updated: Bug was in the database layer"

# Delete a comment
asana-cli task comments delete 9876543210

# Show specific comment with JSON output
asana-cli task comments show 9876543210 --format json
```

## Success Criteria

- [ ] All models implemented with builders
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
| Cannot edit others' comments | Low | Certain | Document clearly, check is_editable flag |
| HTML vs text confusion | Medium | Low | Clear builder API, validation error |
| Pagination performance | Medium | Low | Add limit parameter, document best practices |

## Future Enhancements

- Story reactions/likes
- Story attachments/previews
- Filtering by author
- Search within comments
- Export comments to markdown
