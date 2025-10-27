# Phase 7: Premium Features

**Priority**: LOWER
**Status**: 📋 Planned
**Estimated Effort**: 3-4 hours
**Dependencies**: Phase 2 (workspaces/users)

## Overview

Implement Asana Premium features (Portfolios and Goals) with clear marking in help text and graceful error handling for users without Premium subscriptions.

**User Value**: "I want to track my portfolios via CLI" (if user has Premium) or "Clear messaging when features require upgrade"

## Scope

### In Scope
- Portfolios: list, show, create, update, delete
- Portfolio items: add/remove projects
- Goals: list, show, create, update, delete (basic operations)
- Clear "Premium Required" marking in help text
- Graceful 402/403 error handling with upgrade messaging

### Out of Scope
- Goal metrics and relationships (complex, future)
- Goal parent/supporting relationships
- Portfolio custom fields
- Time periods (used by goals)
- Advanced goal features

## Premium Feature Marking

### Help Text Convention
```
SUBCOMMANDS:
    list        List portfolios [Premium]
    show        Show portfolio details [Premium]
    create      Create a new portfolio [Premium]
```

### Error Handling
When API returns 402 Payment Required or 403 Forbidden:
```rust
match response.status() {
    StatusCode::PAYMENT_REQUIRED => {
        Err(ApiError::PremiumRequired(
            "Portfolios require Asana Premium.\n\
             Upgrade at: https://asana.com/pricing\n\
             Current plan: Free"
        ))
    }
    StatusCode::FORBIDDEN if is_premium_feature(endpoint) => {
        Err(ApiError::FeatureRestricted(
            "This feature is not available on your current plan.\n\
             Visit https://asana.com/pricing for upgrade options."
        ))
    }
    // ... other cases
}
```

## Asana API Endpoints

### Portfolios

| Method | Endpoint | Purpose | Premium |
|--------|----------|---------|---------|
| GET | `/portfolios` | List portfolios | Yes |
| POST | `/portfolios` | Create portfolio | Yes |
| GET | `/portfolios/{portfolio_gid}` | Get portfolio | Yes |
| PUT | `/portfolios/{portfolio_gid}` | Update portfolio | Yes |
| DELETE | `/portfolios/{portfolio_gid}` | Delete portfolio | Yes |
| GET | `/portfolios/{portfolio_gid}/items` | Get portfolio items | Yes |
| POST | `/portfolios/{portfolio_gid}/addItem` | Add project to portfolio | Yes |
| POST | `/portfolios/{portfolio_gid}/removeItem` | Remove project | Yes |

### Goals

| Method | Endpoint | Purpose | Premium |
|--------|----------|---------|---------|
| GET | `/goals` | List goals | Yes |
| POST | `/goals` | Create goal | Yes |
| GET | `/goals/{goal_gid}` | Get goal | Yes |
| PUT | `/goals/{goal_gid}` | Update goal | Yes |
| DELETE | `/goals/{goal_gid}` | Delete goal | Yes |

## Data Models

### File: `src/models/portfolio.rs` (new)

```rust
//! Portfolio data structures for project collections.

use super::{project::Project, user::UserReference, workspace::WorkspaceReference};
use serde::{Deserialize, Serialize};
use std::ops::Deref;
use thiserror::Error;

/// Portfolio color (same as projects/tags).
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "kebab-case")]
pub enum PortfolioColor {
    DarkBlue, DarkBrown, DarkGreen, DarkOrange, DarkPink,
    DarkPurple, DarkRed, DarkTeal, DarkWarmGray,
    LightBlue, LightBrown, LightGreen, LightOrange, LightPink,
    LightPurple, LightRed, LightTeal, LightWarmGray,
    #[serde(other)]
    Unknown,
}

/// Compact portfolio reference.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct PortfolioCompact {
    pub gid: String,
    pub name: String,
    #[serde(default)]
    pub resource_type: Option<String>,
}

/// Full portfolio payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Portfolio {
    pub gid: String,
    pub name: String,
    #[serde(default)]
    pub resource_type: Option<String>,
    #[serde(default)]
    pub color: Option<PortfolioColor>,
    #[serde(default)]
    pub archived: bool,
    #[serde(default)]
    pub created_at: Option<String>,
    #[serde(default)]
    pub created_by: Option<UserReference>,
    #[serde(default)]
    pub due_on: Option<String>,
    #[serde(default)]
    pub start_on: Option<String>,
    #[serde(default)]
    pub workspace: Option<WorkspaceReference>,
    #[serde(default)]
    pub owner: Option<UserReference>,
    #[serde(default)]
    pub permalink_url: Option<String>,
}

/// Parameters for listing portfolios.
#[derive(Debug, Clone, Default)]
pub struct PortfolioListParams {
    pub workspace: String,
    pub owner: Option<String>,
    pub limit: Option<usize>,
}

/// Create portfolio data.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct PortfolioCreateData {
    pub name: String,
    pub workspace: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub color: Option<PortfolioColor>,
}

#[derive(Debug, Clone, Serialize)]
pub struct PortfolioCreateRequest {
    pub data: PortfolioCreateData,
}

/// Update portfolio data.
#[derive(Debug, Clone, Serialize, Default, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct PortfolioUpdateData {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub color: Option<PortfolioColor>,
}

#[derive(Debug, Clone, Serialize)]
pub struct PortfolioUpdateRequest {
    pub data: PortfolioUpdateData,
}

// Builders omitted for brevity - follow same pattern as tags/tasks
```

### File: `src/models/goal.rs` (new)

```rust
//! Goal data structures for objective tracking.

use super::{user::UserReference, workspace::WorkspaceReference};
use serde::{Deserialize, Serialize};

/// Goal status (different from status updates).
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum GoalStatus {
    Green,
    Yellow,
    Red,
}

/// Compact goal reference.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct GoalCompact {
    pub gid: String,
    pub name: String,
    #[serde(default)]
    pub resource_type: Option<String>,
}

/// Full goal payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Goal {
    pub gid: String,
    pub name: String,
    #[serde(default)]
    pub resource_type: Option<String>,
    #[serde(default)]
    pub notes: Option<String>,
    #[serde(default)]
    pub html_notes: Option<String>,
    #[serde(default)]
    pub due_on: Option<String>,
    #[serde(default)]
    pub start_on: Option<String>,
    #[serde(default)]
    pub status: Option<GoalStatus>,
    #[serde(default)]
    pub is_workspace_level: bool,
    #[serde(default)]
    pub workspace: Option<WorkspaceReference>,
    #[serde(default)]
    pub owner: Option<UserReference>,
    #[serde(default)]
    pub followers: Vec<UserReference>,
}

// Parameters and builders follow same patterns
```

## API Operations

### File: `src/api/portfolios.rs` (new)

```rust
//! High level portfolio operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{Portfolio, PortfolioCreateRequest, PortfolioListParams, PortfolioUpdateRequest, Project},
};
use futures_util::{pin_mut, StreamExt};
use serde::Deserialize;

pub async fn list_portfolios(
    client: &ApiClient,
    params: PortfolioListParams,
) -> Result<Vec<Portfolio>, ApiError> {
    let mut query = vec![("workspace".into(), params.workspace.clone())];
    if let Some(owner) = &params.owner {
        query.push(("owner".into(), owner.clone()));
    }

    let stream = client.paginate_with_limit::<Portfolio>("/portfolios", query, params.limit);
    pin_mut!(stream);

    let mut portfolios = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        portfolios.append(&mut page);
    }

    Ok(portfolios)
}

pub async fn get_portfolio(client: &ApiClient, gid: &str) -> Result<Portfolio, ApiError> {
    let response: SinglePortfolioResponse = client
        .get_json_with_pairs(&format!("/portfolios/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

pub async fn create_portfolio(
    client: &ApiClient,
    request: PortfolioCreateRequest,
) -> Result<Portfolio, ApiError> {
    let response: SinglePortfolioResponse = client.post_json("/portfolios", &request).await?;
    Ok(response.data)
}

pub async fn update_portfolio(
    client: &ApiClient,
    gid: &str,
    request: PortfolioUpdateRequest,
) -> Result<Portfolio, ApiError> {
    let response: SinglePortfolioResponse = client
        .put_json(&format!("/portfolios/{gid}"), &request)
        .await?;
    Ok(response.data)
}

pub async fn delete_portfolio(client: &ApiClient, gid: &str) -> Result<(), ApiError> {
    client.delete(&format!("/portfolios/{gid}"), Vec::new()).await
}

pub async fn get_portfolio_items(
    client: &ApiClient,
    portfolio_gid: &str,
) -> Result<Vec<Project>, ApiError> {
    let endpoint = format!("/portfolios/{}/items", portfolio_gid);
    let stream = client.paginate_with_limit::<Project>(&endpoint, vec![], None);
    pin_mut!(stream);

    let mut items = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        items.append(&mut page);
    }

    Ok(items)
}

pub async fn add_portfolio_item(
    client: &ApiClient,
    portfolio_gid: &str,
    item_gid: String,
) -> Result<(), ApiError> {
    #[derive(Serialize)]
    struct AddItemRequest {
        data: AddItemData,
    }
    #[derive(Serialize)]
    struct AddItemData {
        item: String,
    }

    let payload = AddItemRequest {
        data: AddItemData { item: item_gid },
    };

    client
        .post_void(&format!("/portfolios/{portfolio_gid}/addItem"), &payload)
        .await
}

pub async fn remove_portfolio_item(
    client: &ApiClient,
    portfolio_gid: &str,
    item_gid: String,
) -> Result<(), ApiError> {
    #[derive(Serialize)]
    struct RemoveItemRequest {
        data: RemoveItemData,
    }
    #[derive(Serialize)]
    struct RemoveItemData {
        item: String,
    }

    let payload = RemoveItemRequest {
        data: RemoveItemData { item: item_gid },
    };

    client
        .post_void(&format!("/portfolios/{portfolio_gid}/removeItem"), &payload)
        .await
}

#[derive(Debug, Deserialize)]
struct SinglePortfolioResponse {
    data: Portfolio,
}
```

### File: `src/api/goals.rs` (new)

Similar structure to portfolios, ~150 lines.

## Error Handling

### Extend: `src/api/error.rs`

Add new error variants:

```rust
pub enum ApiError {
    // ... existing variants ...

    /// Premium feature accessed without subscription.
    #[error("Premium feature required: {0}")]
    PremiumRequired(String),

    /// Feature restricted on current plan.
    #[error("Feature restricted: {0}")]
    FeatureRestricted(String),
}
```

### Premium Detection Logic

In `src/api/client.rs`, enhance error handling:

```rust
async fn handle_response<T: DeserializeOwned>(
    &self,
    response: Response,
) -> Result<T, ApiError> {
    let status = response.status();

    match status {
        StatusCode::PAYMENT_REQUIRED => {
            let body = response.text().await.unwrap_or_default();
            Err(ApiError::PremiumRequired(format!(
                "This feature requires Asana Premium.\n\
                 Upgrade at: https://asana.com/pricing\n\
                 API response: {}",
                if body.is_empty() { "Payment required" } else { &body }
            )))
        }
        StatusCode::FORBIDDEN => {
            let body = response.text().await.unwrap_or_default();
            if body.contains("premium") || body.contains("upgrade") {
                Err(ApiError::PremiumRequired(format!(
                    "Premium feature access denied.\n\
                     Visit https://asana.com/pricing"
                )))
            } else {
                Err(ApiError::FeatureRestricted(format!(
                    "Access denied: {}",
                    if body.is_empty() { "Forbidden" } else { &body }
                )))
            }
        }
        // ... existing handling
    }
}
```

## CLI Commands

### File: `src/cli/portfolio.rs` (new)

```rust
//! Portfolio CLI command implementations.
//!
//! Note: Portfolios require Asana Premium subscription.

use super::build_api_client;
use crate::{
    api,
    config::Config,
    error::Result,
    models::{Portfolio, PortfolioCreateBuilder, PortfolioListParams, PortfolioUpdateBuilder},
};
use anyhow::{Context, anyhow};
use clap::{Args, Subcommand, ValueEnum};
use colored::Colorize;
use std::io::{IsTerminal, stdout};
use tokio::runtime::Builder as RuntimeBuilder;

#[derive(Subcommand, Debug)]
pub enum PortfolioCommand {
    /// List portfolios [Premium].
    List(PortfolioListArgs),
    /// Show portfolio details [Premium].
    Show(PortfolioShowArgs),
    /// Create a new portfolio [Premium].
    Create(PortfolioCreateArgs),
    /// Update an existing portfolio [Premium].
    Update(PortfolioUpdateArgs),
    /// Delete a portfolio [Premium].
    Delete(PortfolioDeleteArgs),
    /// Manage portfolio items [Premium].
    Items {
        #[command(subcommand)]
        command: PortfolioItemsCommand,
    },
}

#[derive(Subcommand, Debug)]
pub enum PortfolioItemsCommand {
    /// List projects in portfolio [Premium].
    List(PortfolioItemsListArgs),
    /// Add project to portfolio [Premium].
    Add(PortfolioItemsAddArgs),
    /// Remove project from portfolio [Premium].
    Remove(PortfolioItemsRemoveArgs),
}

// Args structs follow existing patterns...

pub fn handle_portfolio_command(command: PortfolioCommand, config: &Config) -> Result<()> {
    let runtime = RuntimeBuilder::new_current_thread()
        .enable_all()
        .build()
        .context("failed to initialise async runtime")?;

    match command {
        PortfolioCommand::List(args) => runtime.block_on(handle_portfolio_list(args, config)),
        PortfolioCommand::Show(args) => runtime.block_on(handle_portfolio_show(args, config)),
        PortfolioCommand::Create(args) => runtime.block_on(handle_portfolio_create(args, config)),
        PortfolioCommand::Update(args) => runtime.block_on(handle_portfolio_update(args, config)),
        PortfolioCommand::Delete(args) => runtime.block_on(handle_portfolio_delete(args, config)),
        PortfolioCommand::Items { command } => {
            runtime.block_on(handle_portfolio_items(command, config))
        }
    }
}

// Implementation functions...
```

### File: `src/cli/goal.rs` (new)

Similar structure to portfolio.rs, ~300 lines.

## File Changes Summary

### New Files
- `src/models/portfolio.rs` (~250 lines)
- `src/models/goal.rs` (~200 lines)
- `src/api/portfolios.rs` (~200 lines)
- `src/api/goals.rs` (~150 lines)
- `src/cli/portfolio.rs` (~350 lines)
- `src/cli/goal.rs` (~300 lines)

### Modified Files
- `src/api/error.rs` - Add premium error variants (~30 lines)
- `src/api/client.rs` - Enhance error handling for 402/403 (~40 lines)
- `src/models/mod.rs` - Export new models
- `src/api/mod.rs` - Export new modules
- `src/cli/mod.rs` - Add Portfolio and Goal commands

## Testing Strategy

### Unit Tests
- Model validation
- Builder patterns
- Serialization/deserialization

### Integration Tests
- **Mock Premium Responses**: Create fixtures for successful Premium API calls
- **Mock 402 Errors**: Test graceful error handling
- List portfolios
- Create/update/delete portfolio
- Add/remove portfolio items
- Goal operations

### Manual Testing Checklist

**If you have Premium**:
- [ ] List portfolios
- [ ] Create portfolio
- [ ] Show portfolio details
- [ ] Update portfolio
- [ ] List portfolio items
- [ ] Add project to portfolio
- [ ] Remove project from portfolio
- [ ] Delete portfolio
- [ ] Create/list/show/delete goal

**If you DON'T have Premium**:
- [ ] Try to list portfolios - verify clear error message
- [ ] Verify error includes upgrade link
- [ ] Verify error is user-friendly, not raw HTTP
- [ ] Try portfolio create - verify same error handling
- [ ] Try goal operations - verify same error handling

## Example Usage

```bash
# List portfolios (Premium required)
asana-cli portfolio list --workspace 1234567890

# Create portfolio (Premium required)
asana-cli portfolio create \
  --name "Q4 2025 Projects" \
  --workspace 1234567890 \
  --color dark-purple

# Show portfolio details
asana-cli portfolio show 9876543210

# List projects in portfolio
asana-cli portfolio items list 9876543210

# Add project to portfolio
asana-cli portfolio items add 9876543210 --project 1111222233

# Remove project from portfolio
asana-cli portfolio items remove 9876543210 --project 1111222233

# Delete portfolio
asana-cli portfolio delete 9876543210

# Goals (similar commands)
asana-cli goal list --workspace 1234567890
asana-cli goal create --name "Increase revenue" --workspace 1234567890
```

## Error Message Examples

### User Without Premium Tries to List Portfolios

**Good**:
```
Error: Premium feature required

Portfolios require an Asana Premium subscription.

Upgrade at: https://asana.com/pricing

Current feature: Portfolios
Required tier: Premium
```

**Bad** (what we're avoiding):
```
Error: 402 Payment Required
```

## Success Criteria

- [ ] Portfolio models and API operations complete
- [ ] Goal models and API operations complete
- [ ] CLI commands with [Premium] marking
- [ ] Error handling for 402/403 with helpful messages
- [ ] Unit tests at 80%+ coverage
- [ ] Integration tests with mocked premium responses
- [ ] Manual testing (with and without Premium)
- [ ] Documentation clearly marks Premium requirements

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Cannot test without Premium | Medium | High | Mock 402 responses, document expected behavior |
| Users frustrated by restricted features | Medium | Medium | Clear messaging, helpful upgrade prompts |
| API changes to premium detection | Low | Low | Monitor Asana changelog, update error parsing |

## Premium Feature List

Features requiring Asana Premium:
- ✅ Portfolios (all operations)
- ✅ Goals (all operations)
- ✅ Custom fields (some advanced features)
- ✅ Forms (not in this plan)
- ✅ Timeline view (UI only)

Features in Free tier:
- ✅ Tasks, Projects, Sections, Tags
- ✅ Comments (Stories)
- ✅ Workspaces, Users, Teams
- ✅ Basic search
- ✅ Attachments

## Future Enhancements

- Goal metrics and progress tracking
- Goal relationships (parent/supporting)
- Portfolio custom fields
- Portfolio members management
- Time periods for goals
- Goal alignment visualization
