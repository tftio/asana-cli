//! Asana API client module providing authenticated HTTP access, pagination,
//! and rate-limit aware retry logic.

pub mod auth;
pub mod client;
pub mod error;
pub mod pagination;
pub mod projects;
pub mod sections;
pub mod tasks;

pub use auth::{AuthToken, StaticTokenProvider, TokenProvider};
pub use client::{ApiClient, ApiClientBuilder, ApiClientOptions};
pub use error::{ApiError, RateLimitInfo};
pub use pagination::{ListResponse, PaginationInfo};
pub use projects::{
    add_members, create_project, delete_project, get_project, list_members, list_projects,
    list_statuses, remove_members, update_member, update_project,
};
pub use sections::{
    add_task_to_section, create_section, get_section, get_section_tasks, list_sections,
};
pub use tasks::{
    add_dependencies, add_dependents, add_followers, add_project, create_task, delete_task,
    get_task, list_dependencies, list_dependents, list_subtasks, list_tasks, remove_dependencies,
    remove_dependents, remove_followers, remove_project, update_task,
};
