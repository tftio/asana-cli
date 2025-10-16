//! High level task operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{Task, TaskCreateRequest, TaskListParams, TaskReference, TaskSort, TaskUpdateRequest},
};
use futures_util::{StreamExt, pin_mut};
use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;

/// Retrieve tasks according to the supplied parameters.
///
/// # Errors
///
/// Returns an error if the API request fails, if deserialization fails, or if the response is invalid.
pub async fn list_tasks(
    client: &ApiClient,
    mut params: TaskListParams,
) -> Result<Vec<Task>, ApiError> {
    ensure_default_fields(&mut params);

    let query = params.to_query();
    let max_items = params.limit;
    let stream = client.paginate_with_limit::<Task>("/tasks", query, max_items);
    pin_mut!(stream);

    let mut tasks = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        tasks.append(&mut page);
    }

    params.apply_post_filters(&mut tasks);

    if let Some(sort) = params.sort {
        sort_tasks(&mut tasks, sort);
    }

    Ok(tasks)
}

/// Retrieve a single task by gid.
///
/// # Errors
///
/// Returns an error if the API request fails, if deserialization fails, or if the response is invalid.
pub async fn get_task(
    client: &ApiClient,
    gid: &str,
    fields: Vec<String>,
) -> Result<Task, ApiError> {
    let mut field_set: BTreeSet<String> = fields.into_iter().collect();
    for field in detail_defaults() {
        field_set.insert(field.to_string());
    }

    let mut query = Vec::new();
    if !field_set.is_empty() {
        query.push((
            "opt_fields".into(),
            field_set.into_iter().collect::<Vec<_>>().join(","),
        ));
    }

    let response: SingleTaskResponse = client
        .get_json_with_pairs(&format!("/tasks/{gid}"), query)
        .await?;
    Ok(response.data)
}

/// Create a task using the provided payload.
///
/// # Errors
///
/// Returns an error if the API request fails, if deserialization fails, or if the response is invalid.
pub async fn create_task(client: &ApiClient, request: TaskCreateRequest) -> Result<Task, ApiError> {
    let response: SingleTaskResponse = client.post_json("/tasks", &request).await?;
    Ok(response.data)
}

/// Update a task using the given payload.
///
/// # Errors
///
/// Returns an error if the API request fails, if deserialization fails, or if the response is invalid.
pub async fn update_task(
    client: &ApiClient,
    gid: &str,
    request: TaskUpdateRequest,
) -> Result<Task, ApiError> {
    let response: SingleTaskResponse = client.put_json(&format!("/tasks/{gid}"), &request).await?;
    Ok(response.data)
}

/// Delete a task permanently.
///
/// # Errors
///
/// Returns an error if the API request fails or if the response is invalid.
pub async fn delete_task(client: &ApiClient, gid: &str) -> Result<(), ApiError> {
    client.delete(&format!("/tasks/{gid}"), Vec::new()).await
}

/// List subtasks for a parent task.
///
/// # Errors
///
/// Returns an error if the API request fails or deserialization fails.
pub async fn list_subtasks(
    client: &ApiClient,
    gid: &str,
    fields: Vec<String>,
) -> Result<Vec<Task>, ApiError> {
    let mut field_set: BTreeSet<String> = fields.into_iter().collect();
    ensure_subtask_fields(&mut field_set);

    let mut query = Vec::new();
    if !field_set.is_empty() {
        let list = field_set.into_iter().collect::<Vec<_>>().join(",");
        query.push(("opt_fields".into(), list));
    }

    let stream = client.paginate_with_limit::<Task>(&format!("/tasks/{gid}/subtasks"), query, None);
    pin_mut!(stream);

    let mut tasks = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        tasks.append(&mut page);
    }
    Ok(tasks)
}

/// Retrieve the tasks that this task depends on.
///
/// # Errors
///
/// Returns an error if the API request fails or deserialization fails.
pub async fn list_dependencies(
    client: &ApiClient,
    gid: &str,
) -> Result<Vec<TaskReference>, ApiError> {
    let response: TaskReferenceResponse = client
        .get_json_with_pairs(&format!("/tasks/{gid}/dependencies"), vec![])
        .await?;
    Ok(response.data)
}

/// Retrieve the tasks blocked by this task.
///
/// # Errors
///
/// Returns an error if the API request fails or deserialization fails.
pub async fn list_dependents(
    client: &ApiClient,
    gid: &str,
) -> Result<Vec<TaskReference>, ApiError> {
    let response: TaskReferenceResponse = client
        .get_json_with_pairs(&format!("/tasks/{gid}/dependents"), vec![])
        .await?;
    Ok(response.data)
}

/// Add dependencies to a task.
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn add_dependencies(
    client: &ApiClient,
    gid: &str,
    dependencies: Vec<String>,
) -> Result<(), ApiError> {
    if dependencies.is_empty() {
        return Ok(());
    }

    let payload = DependencyModifyRequest {
        data: DependencyList { dependencies },
    };
    client
        .post_void(&format!("/tasks/{gid}/addDependencies"), &payload)
        .await
}

/// Remove dependencies from a task.
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn remove_dependencies(
    client: &ApiClient,
    gid: &str,
    dependencies: Vec<String>,
) -> Result<(), ApiError> {
    if dependencies.is_empty() {
        return Ok(());
    }

    let payload = DependencyModifyRequest {
        data: DependencyList { dependencies },
    };
    client
        .post_void(&format!("/tasks/{gid}/removeDependencies"), &payload)
        .await
}

/// Add dependents to a task (tasks blocked by this task).
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn add_dependents(
    client: &ApiClient,
    gid: &str,
    dependents: Vec<String>,
) -> Result<(), ApiError> {
    if dependents.is_empty() {
        return Ok(());
    }

    let payload = DependentModifyRequest {
        data: DependentList { dependents },
    };
    client
        .post_void(&format!("/tasks/{gid}/addDependents"), &payload)
        .await
}

/// Remove dependents from a task.
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn remove_dependents(
    client: &ApiClient,
    gid: &str,
    dependents: Vec<String>,
) -> Result<(), ApiError> {
    if dependents.is_empty() {
        return Ok(());
    }

    let payload = DependentModifyRequest {
        data: DependentList { dependents },
    };
    client
        .post_void(&format!("/tasks/{gid}/removeDependents"), &payload)
        .await
}

/// Add the task to a project, optionally targeting a section.
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn add_project(
    client: &ApiClient,
    gid: &str,
    project: String,
    section: Option<String>,
) -> Result<(), ApiError> {
    let payload = ProjectModifyRequest {
        data: ProjectModifyData { project, section },
    };
    client
        .post_void(&format!("/tasks/{gid}/addProject"), &payload)
        .await
}

/// Remove the task from a project.
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn remove_project(
    client: &ApiClient,
    gid: &str,
    project: String,
) -> Result<(), ApiError> {
    let payload = ProjectModifyRequest {
        data: ProjectModifyData {
            project,
            section: None,
        },
    };
    client
        .post_void(&format!("/tasks/{gid}/removeProject"), &payload)
        .await
}

/// Add followers to a task.
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn add_followers(
    client: &ApiClient,
    gid: &str,
    followers: Vec<String>,
) -> Result<(), ApiError> {
    if followers.is_empty() {
        return Ok(());
    }

    let payload = FollowersModifyRequest {
        data: FollowersList { followers },
    };
    client
        .post_void(&format!("/tasks/{gid}/addFollowers"), &payload)
        .await
}

/// Remove followers from a task.
///
/// # Errors
///
/// Returns an error if the API request fails.
pub async fn remove_followers(
    client: &ApiClient,
    gid: &str,
    followers: Vec<String>,
) -> Result<(), ApiError> {
    if followers.is_empty() {
        return Ok(());
    }

    let payload = FollowersModifyRequest {
        data: FollowersList { followers },
    };
    client
        .post_void(&format!("/tasks/{gid}/removeFollowers"), &payload)
        .await
}

fn ensure_default_fields(params: &mut TaskListParams) {
    let defaults = [
        "gid",
        "name",
        "completed",
        "completed_at",
        "due_on",
        "due_at",
        "start_on",
        "start_at",
        "assignee.name",
        "assignee.gid",
        "assignee.email",
        "resource_type",
        "resource_subtype",
        "modified_at",
        "workspace.name",
        "workspace.gid",
        "projects.name",
        "projects.gid",
        "tags.name",
        "tags.gid",
        "memberships.project.name",
        "memberships.project.gid",
        "memberships.section.name",
        "memberships.section.gid",
        "permalink_url",
    ];
    for field in defaults {
        params.fields.insert(field.to_string());
    }
}

fn detail_defaults() -> &'static [&'static str] {
    &[
        "gid",
        "name",
        "completed",
        "completed_at",
        "due_on",
        "due_at",
        "start_on",
        "start_at",
        "notes",
        "html_notes",
        "assignee",
        "assignee_status",
        "assignee.name",
        "assignee.email",
        "completed_by",
        "created_at",
        "modified_at",
        "workspace",
        "workspace.name",
        "workspace.gid",
        "parent",
        "projects",
        "projects.name",
        "projects.gid",
        "memberships",
        "tags",
        "followers",
        "followers.name",
        "followers.email",
        "dependencies",
        "dependents",
        "custom_fields",
        "attachments",
        "permalink_url",
        "resource_subtype",
    ]
}

fn ensure_subtask_fields(fields: &mut BTreeSet<String>) {
    if fields.is_empty() {
        let defaults = ["gid", "name", "completed", "assignee.name"];
        for field in defaults {
            fields.insert(field.to_string());
        }
    }
}

fn sort_tasks(tasks: &mut [Task], sort: TaskSort) {
    match sort {
        TaskSort::Name => tasks.sort_by(|a, b| {
            a.name
                .to_ascii_lowercase()
                .cmp(&b.name.to_ascii_lowercase())
        }),
        TaskSort::DueOn => tasks.sort_by(|a, b| {
            a.due_on
                .cmp(&b.due_on)
                .then_with(|| a.due_at.cmp(&b.due_at))
        }),
        TaskSort::CreatedAt => tasks.sort_by(|a, b| a.created_at.cmp(&b.created_at)),
        TaskSort::ModifiedAt => tasks.sort_by(|a, b| a.modified_at.cmp(&b.modified_at)),
        TaskSort::Assignee => tasks.sort_by(|a, b| assignee_label(a).cmp(&assignee_label(b))),
    }
}

fn assignee_label(task: &Task) -> Option<String> {
    task.assignee.as_ref().map(|assignee| assignee.label())
}

#[derive(Debug, Deserialize)]
struct SingleTaskResponse {
    data: Task,
}

#[derive(Debug, Deserialize)]
struct TaskReferenceResponse {
    data: Vec<TaskReference>,
}

#[derive(Debug, Serialize)]
struct DependencyModifyRequest {
    data: DependencyList,
}

#[derive(Debug, Serialize)]
struct DependencyList {
    #[serde(skip_serializing_if = "Vec::is_empty")]
    dependencies: Vec<String>,
}

#[derive(Debug, Serialize)]
struct DependentModifyRequest {
    data: DependentList,
}

#[derive(Debug, Serialize)]
struct DependentList {
    #[serde(skip_serializing_if = "Vec::is_empty")]
    dependents: Vec<String>,
}

#[derive(Debug, Serialize)]
struct ProjectModifyRequest {
    data: ProjectModifyData,
}

#[derive(Debug, Serialize)]
struct ProjectModifyData {
    project: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    section: Option<String>,
}

#[derive(Debug, Serialize)]
struct FollowersModifyRequest {
    data: FollowersList,
}

#[derive(Debug, Serialize)]
struct FollowersList {
    #[serde(skip_serializing_if = "Vec::is_empty")]
    followers: Vec<String>,
}
