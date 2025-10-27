# Phase 8: Enterprise Features

**Priority**: LOWEST
**Status**: 📋 Planned
**Estimated Effort**: 2-3 hours
**Dependencies**: Phase 2 (workspaces)

## Overview

Implement Asana Enterprise-only features with clear marking and graceful error handling. These features are primarily for compliance, security, and integration use cases in large organizations.

**User Value**: "Clear messaging that these features require Enterprise" or "Webhook management for integrations"

## Scope

### In Scope
- Webhooks: list, create, update, delete (useful for integrations)
- Audit Log: read-only access (Enterprise only)
- Organization Exports: initiate and check status (Enterprise only)
- Clear "Enterprise Required" marking
- Graceful error handling for 403 Forbidden

### Out of Scope
- Webhook event handling (server-side, not CLI)
- Audit log analysis/parsing
- Export data processing
- SCIM operations (enterprise user provisioning)

## Enterprise Feature Marking

### Help Text Convention
```
SUBCOMMANDS:
    webhook     Manage webhooks [Enterprise]
    audit-log   View audit log events [Enterprise]
    export      Manage organization exports [Enterprise]
```

### Error Handling
Similar to Premium features (Phase 7), but with Enterprise-specific messaging:

```rust
StatusCode::FORBIDDEN if is_enterprise_feature(endpoint) => {
    Err(ApiError::EnterpriseRequired(
        "This feature requires Asana Enterprise.\n\
         Contact your organization admin or visit:\n\
         https://asana.com/enterprise"
    ))
}
```

## Asana API Endpoints

### Webhooks

| Method | Endpoint | Purpose | Enterprise |
|--------|----------|---------|-----------|
| GET | `/webhooks` | List webhooks | No* |
| POST | `/webhooks` | Create webhook | No* |
| GET | `/webhooks/{webhook_gid}` | Get webhook | No* |
| PUT | `/webhooks/{webhook_gid}` | Update webhook | No* |
| DELETE | `/webhooks/{webhook_gid}` | Delete webhook | No* |

*Webhooks are available on all tiers but mainly used for integrations

### Audit Log API

| Method | Endpoint | Purpose | Enterprise |
|--------|----------|---------|-----------|
| GET | `/audit_log_events` | Get audit events | Yes |

**Note**: Requires Service Account with Personal Access Token

### Organization Exports

| Method | Endpoint | Purpose | Enterprise |
|--------|----------|---------|-----------|
| POST | `/organization_exports` | Create export | Yes |
| GET | `/organization_exports/{export_gid}` | Get export status | Yes |

## Data Models

### File: `src/models/webhook.rs` (new)

```rust
//! Webhook data structures for event subscriptions.

use serde::{Deserialize, Serialize};
use std::ops::Deref;
use thiserror::Error;

/// Webhook filter resource type.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum WebhookResourceType {
    Task,
    Project,
    Portfolio,
    Goal,
    Team,
    Workspace,
}

/// Webhook filter action.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum WebhookAction {
    Changed,
    Added,
    Removed,
    Deleted,
    Undeleted,
}

/// Webhook filter.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct WebhookFilter {
    pub resource_type: WebhookResourceType,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub resource_subtype: Option<String>,
    pub action: WebhookAction,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub fields: Vec<String>,
}

/// Resource reference for webhook.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct WebhookResource {
    pub gid: String,
    #[serde(default)]
    pub resource_type: Option<String>,
    #[serde(default)]
    pub name: Option<String>,
}

/// Compact webhook reference.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct WebhookCompact {
    pub gid: String,
    #[serde(default)]
    pub resource_type: Option<String>,
    pub active: bool,
    pub resource: WebhookResource,
    pub target: String,
}

/// Full webhook payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Webhook {
    pub gid: String,
    #[serde(default)]
    pub resource_type: Option<String>,
    pub active: bool,
    pub resource: WebhookResource,
    pub target: String,
    #[serde(default)]
    pub created_at: Option<String>,
    #[serde(default)]
    pub last_success_at: Option<String>,
    #[serde(default)]
    pub last_failure_at: Option<String>,
    #[serde(default)]
    pub last_failure_content: Option<String>,
    #[serde(default)]
    pub filters: Vec<WebhookFilter>,
}

/// Create webhook data.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct WebhookCreateData {
    pub resource: String,
    pub target: String,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub filters: Vec<WebhookFilter>,
}

#[derive(Debug, Clone, Serialize)]
pub struct WebhookCreateRequest {
    pub data: WebhookCreateData,
}

// Builder and update structs follow standard patterns...
```

### File: `src/models/audit_log.rs` (new)

```rust
//! Audit log event data structures (Enterprise only).

use super::user::UserReference;
use serde::{Deserialize, Serialize};

/// Audit log event type.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum AuditLogEventType {
    TaskCreated,
    TaskDeleted,
    ProjectCreated,
    ProjectDeleted,
    UserAdded,
    UserRemoved,
    // ... many more event types
    #[serde(other)]
    Unknown,
}

/// Audit log actor (who performed the action).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct AuditLogActor {
    pub actor_type: String,
    #[serde(default)]
    pub gid: Option<String>,
    #[serde(default)]
    pub name: Option<String>,
    #[serde(default)]
    pub email: Option<String>,
}

/// Audit log event.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct AuditLogEvent {
    pub gid: String,
    #[serde(default)]
    pub resource_type: Option<String>,
    pub event_type: AuditLogEventType,
    pub actor: AuditLogActor,
    pub created_at: String,
    #[serde(default)]
    pub details: serde_json::Value,
}

/// Parameters for querying audit log.
#[derive(Debug, Clone)]
pub struct AuditLogParams {
    pub workspace: String,
    pub start_at: Option<String>,
    pub end_at: Option<String>,
    pub event_type: Option<String>,
    pub actor_type: Option<String>,
    pub limit: Option<usize>,
}
```

## API Operations

### File: `src/api/webhooks.rs` (new)

```rust
//! Webhook operations.

use crate::{
    api::{ApiClient, ApiError},
    models::{Webhook, WebhookCreateRequest, WebhookUpdateRequest},
};
use futures_util::{pin_mut, StreamExt};
use serde::Deserialize;

pub async fn list_webhooks(
    client: &ApiClient,
    workspace: &str,
) -> Result<Vec<Webhook>, ApiError> {
    let query = vec![("workspace".into(), workspace.to_string())];
    let stream = client.paginate_with_limit::<Webhook>("/webhooks", query, None);
    pin_mut!(stream);

    let mut webhooks = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        webhooks.append(&mut page);
    }

    Ok(webhooks)
}

pub async fn get_webhook(client: &ApiClient, gid: &str) -> Result<Webhook, ApiError> {
    let response: SingleWebhookResponse = client
        .get_json_with_pairs(&format!("/webhooks/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

pub async fn create_webhook(
    client: &ApiClient,
    request: WebhookCreateRequest,
) -> Result<Webhook, ApiError> {
    let response: SingleWebhookResponse = client.post_json("/webhooks", &request).await?;
    Ok(response.data)
}

pub async fn update_webhook(
    client: &ApiClient,
    gid: &str,
    request: WebhookUpdateRequest,
) -> Result<Webhook, ApiError> {
    let response: SingleWebhookResponse = client
        .put_json(&format!("/webhooks/{gid}"), &request)
        .await?;
    Ok(response.data)
}

pub async fn delete_webhook(client: &ApiClient, gid: &str) -> Result<(), ApiError> {
    client.delete(&format!("/webhooks/{gid}"), Vec::new()).await
}

#[derive(Debug, Deserialize)]
struct SingleWebhookResponse {
    data: Webhook,
}
```

### File: `src/api/audit_log.rs` (new)

```rust
//! Audit log operations (Enterprise only).

use crate::{
    api::{ApiClient, ApiError},
    models::{AuditLogEvent, AuditLogParams},
};
use futures_util::{pin_mut, StreamExt};

pub async fn get_audit_log_events(
    client: &ApiClient,
    params: AuditLogParams,
) -> Result<Vec<AuditLogEvent>, ApiError> {
    let mut query = vec![("workspace".into(), params.workspace.clone())];

    if let Some(start) = &params.start_at {
        query.push(("start_at".into(), start.clone()));
    }
    if let Some(end) = &params.end_at {
        query.push(("end_at".into(), end.clone()));
    }
    if let Some(event_type) = &params.event_type {
        query.push(("event_type".into(), event_type.clone()));
    }
    if let Some(actor_type) = &params.actor_type {
        query.push(("actor_type".into(), actor_type.clone()));
    }

    let stream = client.paginate_with_limit::<AuditLogEvent>(
        "/audit_log_events",
        query,
        params.limit,
    );
    pin_mut!(stream);

    let mut events = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        events.append(&mut page);
    }

    Ok(events)
}
```

## CLI Commands

### File: `src/cli/webhook.rs` (new)

```rust
//! Webhook CLI command implementations.

use super::build_api_client;
use crate::{
    api,
    config::Config,
    error::Result,
    models::{Webhook, WebhookCreateBuilder},
};
use anyhow::Context;
use clap::{Args, Subcommand, ValueEnum};
use tokio::runtime::Builder as RuntimeBuilder;

#[derive(Subcommand, Debug)]
pub enum WebhookCommand {
    /// List webhooks.
    List(WebhookListArgs),
    /// Show webhook details.
    Show(WebhookShowArgs),
    /// Create a webhook.
    Create(WebhookCreateArgs),
    /// Update a webhook.
    Update(WebhookUpdateArgs),
    /// Delete a webhook.
    Delete(WebhookDeleteArgs),
}

// Args structs and handlers...
```

### File: `src/cli/audit_log.rs` (new)

```rust
//! Audit log CLI command implementations.
//!
//! Note: Audit Log API requires Asana Enterprise and Service Account.

use super::build_api_client;
use crate::{
    api,
    config::Config,
    error::Result,
    models::{AuditLogEvent, AuditLogParams},
};
use anyhow::{Context, anyhow};
use clap::{Args, Subcommand, ValueEnum};
use colored::Colorize;
use std::io::{IsTerminal, stdout};
use tokio::runtime::Builder as RuntimeBuilder;

#[derive(Subcommand, Debug)]
pub enum AuditLogCommand {
    /// List audit log events [Enterprise].
    Events(AuditLogEventsArgs),
}

#[derive(Args, Debug)]
pub struct AuditLogEventsArgs {
    /// Workspace identifier.
    #[arg(long)]
    pub workspace: Option<String>,
    /// Start timestamp (ISO 8601).
    #[arg(long)]
    pub start_at: Option<String>,
    /// End timestamp (ISO 8601).
    #[arg(long)]
    pub end_at: Option<String>,
    /// Event type filter.
    #[arg(long)]
    pub event_type: Option<String>,
    /// Actor type filter.
    #[arg(long)]
    pub actor_type: Option<String>,
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum, default_value = "table")]
    pub format: OutputFormat,
}

pub fn handle_audit_log_command(command: AuditLogCommand, config: &Config) -> Result<()> {
    let runtime = RuntimeBuilder::new_current_thread()
        .enable_all()
        .build()
        .context("failed to initialise async runtime")?;

    match command {
        AuditLogCommand::Events(args) => runtime.block_on(handle_audit_log_events(args, config)),
    }
}

async fn handle_audit_log_events(args: AuditLogEventsArgs, config: &Config) -> Result<()> {
    let client = build_api_client(config)?;

    let workspace = args
        .workspace
        .or_else(|| config.default_workspace().map(String::from))
        .ok_or_else(|| anyhow!("workspace is required"))?;

    let params = AuditLogParams {
        workspace,
        start_at: args.start_at,
        end_at: args.end_at,
        event_type: args.event_type,
        actor_type: args.actor_type,
        limit: args.limit,
    };

    let events = api::get_audit_log_events(&client, params)
        .await
        .context("failed to get audit log events")?;

    match args.format {
        OutputFormat::Table => render_audit_log_table(&events),
        OutputFormat::Detail => {
            for event in &events {
                render_audit_log_detail(event);
                println!();
            }
        }
        OutputFormat::Json => {
            let json = serde_json::to_string_pretty(&events)?;
            println!("{json}");
        }
    }

    Ok(())
}

fn render_audit_log_table(events: &[AuditLogEvent]) {
    if events.is_empty() {
        println!("No audit log events found.");
        return;
    }

    let is_tty = stdout().is_terminal();
    if is_tty {
        println!(
            "{:<30} {:<25} {:<25}",
            "Event Type".bold(),
            "Actor".bold(),
            "Timestamp".bold()
        );
        println!("{}", "─".repeat(80));
    }

    for event in events {
        let event_type = format!("{:?}", event.event_type);
        let actor_name = event.actor.name.as_deref().unwrap_or("unknown");

        if is_tty {
            println!("{:<30} {:<25} {:<25}", event_type, actor_name, event.created_at);
        } else {
            println!("{}\t{}\t{}", event_type, actor_name, event.created_at);
        }
    }

    if is_tty {
        println!("\n{} events found.", events.len());
    }
}

fn render_audit_log_detail(event: &AuditLogEvent) {
    let is_tty = stdout().is_terminal();
    let event_type = format!("{:?}", event.event_type);

    if is_tty {
        println!("{}", "Audit Log Event".bold().underline());
        println!("  {}: {}", "GID".bold(), event.gid);
        println!("  {}: {}", "Event Type".bold(), event_type);
        println!("  {}: {}", "Actor".bold(), event.actor.name.as_deref().unwrap_or("unknown"));
        if let Some(email) = &event.actor.email {
            println!("  {}: {}", "Actor Email".bold(), email);
        }
        println!("  {}: {}", "Timestamp".bold(), event.created_at);
        if !event.details.is_null() {
            let details = serde_json::to_string_pretty(&event.details).unwrap_or_default();
            println!("  {}:\n{}", "Details".bold(), details);
        }
    } else {
        println!("GID: {}", event.gid);
        println!("Event Type: {}", event_type);
        println!("Actor: {}", event.actor.name.as_deref().unwrap_or("unknown"));
        println!("Timestamp: {}", event.created_at);
    }
}
```

## File Changes Summary

### New Files
- `src/models/webhook.rs` (~200 lines)
- `src/models/audit_log.rs` (~100 lines)
- `src/models/organization_export.rs` (~80 lines)
- `src/api/webhooks.rs` (~120 lines)
- `src/api/audit_log.rs` (~60 lines)
- `src/api/organization_exports.rs` (~80 lines)
- `src/cli/webhook.rs` (~300 lines)
- `src/cli/audit_log.rs` (~200 lines)

### Modified Files
- `src/api/error.rs` - Add EnterpriseRequired variant (~20 lines)
- `src/api/client.rs` - Enhance error detection (~30 lines)
- `src/models/mod.rs` - Export new models
- `src/api/mod.rs` - Export new modules
- `src/cli/mod.rs` - Add Webhook and AuditLog commands

## Testing Strategy

### Unit Tests
- Webhook filter validation
- Model serialization
- Error variant construction

### Integration Tests
- **Mock Enterprise Responses**: Test with successful Enterprise responses
- **Mock 403 Errors**: Test graceful Enterprise error handling
- Webhook CRUD operations
- Audit log querying
- Organization export status

### Manual Testing Checklist

**Webhooks** (available on all tiers):
- [ ] List webhooks for workspace
- [ ] Create webhook for task resource
- [ ] Show webhook details
- [ ] Update webhook (activate/deactivate)
- [ ] Delete webhook
- [ ] Test with filters

**If you have Enterprise**:
- [ ] List audit log events
- [ ] Filter by event type
- [ ] Filter by date range
- [ ] Filter by actor
- [ ] Verify output formats

**If you DON'T have Enterprise**:
- [ ] Try audit log - verify clear error message
- [ ] Verify error includes Enterprise upgrade info
- [ ] Verify error is user-friendly

## Example Usage

```bash
# Webhooks (available on all tiers)
asana-cli webhook list --workspace 1234567890

asana-cli webhook create \
  --resource 1234567890 \
  --target "https://example.com/webhook" \
  --filter-resource task \
  --filter-action changed

asana-cli webhook show 9876543210
asana-cli webhook delete 9876543210

# Audit Log (Enterprise only)
asana-cli audit-log events --workspace 1234567890

asana-cli audit-log events \
  --workspace 1234567890 \
  --start-at 2025-10-01T00:00:00Z \
  --end-at 2025-10-31T23:59:59Z \
  --event-type task_deleted

asana-cli audit-log events \
  --workspace 1234567890 \
  --actor-type user \
  --format json > audit-log.json
```

## Enterprise Error Messages

### Audit Log Without Enterprise

**Good**:
```
Error: Enterprise feature required

The Audit Log API requires Asana Enterprise.

This feature provides:
- Immutable log of security and compliance events
- SIEM integration capabilities
- Access requires Service Account authentication

Contact your organization admin or visit:
https://asana.com/enterprise
```

**Bad** (what we're avoiding):
```
Error: 403 Forbidden
```

## Success Criteria

- [ ] Webhook models and operations complete
- [ ] Audit log models and operations complete
- [ ] CLI commands with [Enterprise] marking
- [ ] Error handling for 403 with helpful messages
- [ ] Unit tests at 80%+ coverage
- [ ] Integration tests with mocked responses
- [ ] Manual testing complete
- [ ] Documentation marks Enterprise requirements

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Cannot test Enterprise features | High | High | Mock 403 responses, clear documentation |
| Webhook event handling confusion | Medium | Medium | Document that webhooks are for integrations, not CLI |
| Service Account requirement unclear | Medium | Low | Document auth requirements in help text |

## Enterprise Feature List

Features requiring Asana Enterprise:
- ✅ Audit Log API (read-only)
- ✅ Service Accounts
- ✅ Advanced security controls
- ✅ SAML SSO
- ✅ Organization exports

Features NOT Enterprise-only:
- ✅ Webhooks (available on all tiers)
- ✅ API access (available on all tiers)

## Notes on Webhooks

### Webhook Use Cases
Webhooks are primarily for **server-side integrations**, not interactive CLI use:
- CI/CD triggers when tasks complete
- Slack notifications on task changes
- External system synchronization
- Analytics/reporting pipelines

### CLI Webhook Utility
Limited CLI use cases:
- Set up webhooks for testing
- Debug webhook delivery issues
- Manage webhook lifecycle
- Inspect webhook configuration

### Recommendation
Include webhooks but document clearly:
```
Note: Webhooks are designed for integrations and automation.
      The CLI can create/manage webhooks, but cannot receive events.
      For event handling, use a web server or integration platform.
```

## Future Enhancements

- Webhook event simulator (test webhook without server)
- Webhook delivery logs visualization
- Audit log export to CSV
- Audit log filtering by resource
- Organization export download
- Batch export operations
