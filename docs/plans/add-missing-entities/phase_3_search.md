# Phase 3: Search

**Priority**: HIGH
**Status**: 📋 Planned
**Estimated Effort**: 3-4 hours
**Dependencies**: Phase 2 (workspace discovery)

## Overview

Implement workspace-scoped full-text task search with filters. This enables users to quickly find tasks by content, name, or metadata across their workspace.

**User Value**: "I need to find all tasks containing 'API bug'" or "Show me all my incomplete tasks with 'urgent' in the name"

## Scope

### In Scope
- Full-text search across task names and notes
- Workspace-scoped search only
- Filter by: assignee, project, completed status, due dates
- Respect existing output formats (table, json, detail)
- Pagination support

### Out of Scope
- Cross-workspace search (deferred)
- Search in comments/stories (future enhancement)
- Search in custom fields (future enhancement)
- Saved searches (future enhancement)
- Search highlighting in results

## Asana API Endpoints

| Method | Endpoint | Purpose | Scope Required |
|--------|----------|---------|----------------|
| GET | `/workspaces/{workspace_gid}/tasks/search` | Search tasks in workspace | default |

### Query Parameters
- `text` - Full-text search query
- `resource_subtype` - Filter by task type (default_task, milestone, etc.)
- `completed` - Filter by completion status
- `is_subtask` - Include/exclude subtasks
- `is_blocked` - Filter blocked tasks
- `has_attachment` - Filter tasks with attachments
- `assignee.any` - Filter by assignee
- `projects.any` - Filter by project
- `sections.any` - Filter by section
- `tags.any` - Filter by tag
- `created_at.after` / `created_at.before` - Date range filters
- `modified_at.after` / `modified_at.before` - Date range filters
- `due_on.after` / `due_on.before` - Due date range
- `sort_by` - Sort field (likes, modified_at, etc.)
- `sort_ascending` - Sort direction

## Data Models

### Extend: `src/models/task.rs`

```rust
/// Parameters for searching tasks.
#[derive(Debug, Clone)]
pub struct TaskSearchParams {
    /// Workspace to search in (required).
    pub workspace: String,
    /// Full-text search query.
    pub text: Option<String>,
    /// Resource subtype filter.
    pub resource_subtype: Option<String>,
    /// Completion status filter.
    pub completed: Option<bool>,
    /// Include subtasks.
    pub is_subtask: Option<bool>,
    /// Filter blocked tasks.
    pub is_blocked: Option<bool>,
    /// Filter tasks with attachments.
    pub has_attachment: Option<bool>,
    /// Assignee filter (gid or "me").
    pub assignee: Option<String>,
    /// Project filter (gid).
    pub projects: Vec<String>,
    /// Section filter (gid).
    pub sections: Vec<String>,
    /// Tag filter (gid).
    pub tags: Vec<String>,
    /// Created after date (YYYY-MM-DD).
    pub created_after: Option<String>,
    /// Created before date (YYYY-MM-DD).
    pub created_before: Option<String>,
    /// Modified after date (YYYY-MM-DD).
    pub modified_after: Option<String>,
    /// Modified before date (YYYY-MM-DD).
    pub modified_before: Option<String>,
    /// Due after date (YYYY-MM-DD).
    pub due_after: Option<String>,
    /// Due before date (YYYY-MM-DD).
    pub due_before: Option<String>,
    /// Sort field.
    pub sort_by: Option<String>,
    /// Sort ascending.
    pub sort_ascending: bool,
    /// Maximum number of items to fetch.
    pub limit: Option<usize>,
    /// Additional fields to request.
    pub fields: BTreeSet<String>,
}

impl TaskSearchParams {
    /// Convert to query parameters.
    #[must_use]
    pub fn to_query(&self) -> Vec<(String, String)> {
        let mut pairs = Vec::new();

        if let Some(text) = &self.text {
            pairs.push(("text".into(), text.clone()));
        }
        if let Some(subtype) = &self.resource_subtype {
            pairs.push(("resource_subtype".into(), subtype.clone()));
        }
        if let Some(completed) = self.completed {
            pairs.push(("completed".into(), completed.to_string()));
        }
        if let Some(is_subtask) = self.is_subtask {
            pairs.push(("is_subtask".into(), is_subtask.to_string()));
        }
        if let Some(is_blocked) = self.is_blocked {
            pairs.push(("is_blocked".into(), is_blocked.to_string()));
        }
        if let Some(has_attachment) = self.has_attachment {
            pairs.push(("has_attachment".into(), has_attachment.to_string()));
        }
        if let Some(assignee) = &self.assignee {
            pairs.push(("assignee.any".into(), assignee.clone()));
        }

        for project in &self.projects {
            pairs.push(("projects.any".into(), project.clone()));
        }
        for section in &self.sections {
            pairs.push(("sections.any".into(), section.clone()));
        }
        for tag in &self.tags {
            pairs.push(("tags.any".into(), tag.clone()));
        }

        if let Some(date) = &self.created_after {
            pairs.push(("created_at.after".into(), date.clone()));
        }
        if let Some(date) = &self.created_before {
            pairs.push(("created_at.before".into(), date.clone()));
        }
        if let Some(date) = &self.modified_after {
            pairs.push(("modified_at.after".into(), date.clone()));
        }
        if let Some(date) = &self.modified_before {
            pairs.push(("modified_at.before".into(), date.clone()));
        }
        if let Some(date) = &self.due_after {
            pairs.push(("due_on.after".into(), date.clone()));
        }
        if let Some(date) = &self.due_before {
            pairs.push(("due_on.before".into(), date.clone()));
        }

        if let Some(sort_by) = &self.sort_by {
            pairs.push(("sort_by".into(), sort_by.clone()));
            pairs.push(("sort_ascending".into(), self.sort_ascending.to_string()));
        }

        if !self.fields.is_empty() {
            let field_list = self.fields.iter().cloned().collect::<Vec<_>>().join(",");
            pairs.push(("opt_fields".into(), field_list));
        }

        pairs
    }
}

impl Default for TaskSearchParams {
    fn default() -> Self {
        Self {
            workspace: String::new(),
            text: None,
            resource_subtype: None,
            completed: None,
            is_subtask: None,
            is_blocked: None,
            has_attachment: None,
            assignee: None,
            projects: Vec::new(),
            sections: Vec::new(),
            tags: Vec::new(),
            created_after: None,
            created_before: None,
            modified_after: None,
            modified_before: None,
            due_after: None,
            due_before: None,
            sort_by: None,
            sort_ascending: false,
            limit: None,
            fields: BTreeSet::new(),
        }
    }
}
```

## API Operations

### Extend: `src/api/tasks.rs`

Add new function:

```rust
/// Search tasks in a workspace.
///
/// # Errors
///
/// Returns an error if the API request fails, if deserialization fails, or if the response is invalid.
pub async fn search_tasks(
    client: &ApiClient,
    mut params: TaskSearchParams,
) -> Result<Vec<Task>, ApiError> {
    ensure_default_fields_for_search(&mut params);

    let query = params.to_query();
    let max_items = params.limit;
    let endpoint = format!("/workspaces/{}/tasks/search", params.workspace);
    let stream = client.paginate_with_limit::<Task>(&endpoint, query, max_items);
    pin_mut!(stream);

    let mut tasks = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        tasks.append(&mut page);
    }

    Ok(tasks)
}

fn ensure_default_fields_for_search(params: &mut TaskSearchParams) {
    // Add same defaults as list_tasks
    let defaults = [
        "gid", "name", "completed", "completed_at",
        "due_on", "due_at", "start_on", "start_at",
        "assignee.name", "assignee.gid", "assignee.email",
        "resource_type", "resource_subtype",
        "modified_at", "workspace.name", "workspace.gid",
        "projects.name", "projects.gid",
        "tags.name", "tags.gid",
        "memberships.project.name", "memberships.project.gid",
        "memberships.section.name", "memberships.section.gid",
        "permalink_url", "num_subtasks",
    ];
    for field in defaults {
        params.fields.insert(field.to_string());
    }
}
```

## CLI Commands

### Extend: `src/cli/task.rs`

Update `TaskCommand` enum:
```rust
/// Search for tasks with fuzzy matching.
Search(TaskSearchArgs),
```

Update `TaskSearchArgs`:
```rust
#[derive(Args, Debug)]
pub struct TaskSearchArgs {
    /// Full-text search query.
    #[arg(long)]
    pub query: Option<String>,
    /// Workspace identifier (required).
    #[arg(long)]
    pub workspace: Option<String>,
    /// Filter by assignee (gid or email).
    #[arg(long)]
    pub assignee: Option<String>,
    /// Filter by project.
    #[arg(long = "project", value_name = "PROJECT")]
    pub projects: Vec<String>,
    /// Filter by section.
    #[arg(long = "section", value_name = "SECTION")]
    pub sections: Vec<String>,
    /// Filter by tag.
    #[arg(long = "tag", value_name = "TAG")]
    pub tags: Vec<String>,
    /// Filter by completion status.
    #[arg(long)]
    pub completed: Option<bool>,
    /// Include subtasks.
    #[arg(long)]
    pub include_subtasks: bool,
    /// Filter blocked tasks.
    #[arg(long)]
    pub blocked: Option<bool>,
    /// Filter tasks with attachments.
    #[arg(long)]
    pub has_attachments: Option<bool>,
    /// Created after date (YYYY-MM-DD).
    #[arg(long)]
    pub created_after: Option<String>,
    /// Created before date (YYYY-MM-DD).
    #[arg(long)]
    pub created_before: Option<String>,
    /// Modified after date (YYYY-MM-DD).
    #[arg(long)]
    pub modified_after: Option<String>,
    /// Modified before date (YYYY-MM-DD).
    #[arg(long)]
    pub modified_before: Option<String>,
    /// Due after date (YYYY-MM-DD).
    #[arg(long)]
    pub due_after: Option<String>,
    /// Due before date (YYYY-MM-DD).
    #[arg(long)]
    pub due_before: Option<String>,
    /// Sort by field (modified_at, likes, created_at).
    #[arg(long)]
    pub sort_by: Option<String>,
    /// Sort ascending (default: descending).
    #[arg(long)]
    pub sort_ascending: bool,
    /// Maximum number to retrieve.
    #[arg(long)]
    pub limit: Option<usize>,
    /// Output format.
    #[arg(long, value_enum)]
    pub output: Option<TaskOutputFormat>,
}
```

Update `search_task_command()` implementation to use the search API instead of fuzzy matching.

## File Changes Summary

### New Files
None (extends existing)

### Modified Files
- `src/models/task.rs` - Add TaskSearchParams (~120 lines)
- `src/api/tasks.rs` - Add search_tasks function (~40 lines)
- `src/cli/task.rs` - Update TaskSearchArgs and implementation (~100 lines modified)
- `src/models/mod.rs` - Export TaskSearchParams

## Testing Strategy

### Unit Tests
- TaskSearchParams query parameter generation
- Filter combinations
- Field set handling

### Integration Tests
- Search with text query
- Search with multiple filters
- Search with date ranges
- Empty results handling
- Pagination with large result sets

### Manual Testing Checklist
- [ ] Search by text query
- [ ] Search with assignee filter
- [ ] Search with project filter
- [ ] Search with multiple tags
- [ ] Search with date ranges
- [ ] Search completed tasks only
- [ ] Search blocked tasks
- [ ] Search with sorting
- [ ] Search with limit
- [ ] Test empty results
- [ ] Test output formats (table, json, detail)
- [ ] Verify default workspace from config

## Example Usage

```bash
# Basic text search
asana-cli task search --query "API bug" --workspace 1234567890

# Search my incomplete tasks
asana-cli task search --assignee me --completed false --workspace 1234567890

# Search in specific project
asana-cli task search --query "urgent" --project 9876543210 --workspace 1234567890

# Complex search with multiple filters
asana-cli task search \
  --query "database" \
  --assignee me \
  --tag 111222333 \
  --due-after 2025-10-01 \
  --due-before 2025-10-31 \
  --workspace 1234567890

# Search blocked tasks
asana-cli task search --blocked true --workspace 1234567890

# Search with sorting
asana-cli task search --query "bug" --sort-by modified_at --workspace 1234567890

# Use default workspace from config
asana-cli config set workspace --workspace 1234567890
asana-cli task search --query "API"

# JSON output for piping
asana-cli task search --query "urgent" --workspace 1234567890 --format json | jq '.[] | .name'
```

## Success Criteria

- [ ] TaskSearchParams implemented and tested
- [ ] search_tasks API function working
- [ ] CLI search command with all filters
- [ ] Unit tests at 80%+ coverage
- [ ] Integration tests pass
- [ ] Clippy pedantic passes
- [ ] Manual testing complete
- [ ] README updated with search examples

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Search performance slow | Medium | Medium | Add limit parameter, document pagination |
| Complex filter combinations | Low | Low | Clear help text, examples in documentation |
| API rate limiting on large searches | Medium | Low | Respect pagination, add delays if needed |

## Performance Considerations

### API Rate Limiting
- Asana has rate limits: ~150 requests/minute
- Search counts as regular API call
- Large result sets require pagination

### Optimization Strategies
1. **Always specify limit**: `--limit 50` for faster responses
2. **Use specific filters**: Narrow search with assignee/project
3. **Leverage workspace default**: Store in config to avoid typing

### Expected Performance
- Small workspace (<1000 tasks): <2 seconds
- Medium workspace (<10,000 tasks): 2-5 seconds
- Large workspace (>10,000 tasks): May require pagination

## Future Enhancements

- Cross-workspace search
- Search in task comments/stories
- Search in custom field values
- Saved search templates
- Search result highlighting
- Export search results to CSV
- Search history/recent searches
