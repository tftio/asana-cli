//! Attachment metadata returned alongside tasks.

use serde::{Deserialize, Serialize};

/// File attachment associated with a task or comment.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Attachment {
    /// Globally unique identifier.
    pub gid: String,
    /// Display name for the attachment.
    pub name: String,
    /// Resource type marker reported by Asana.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Additional subtype information (e.g., "asana", "dropbox").
    #[serde(default)]
    pub resource_subtype: Option<String>,
    /// Creation timestamp.
    #[serde(default)]
    pub created_at: Option<String>,
    /// Host provider identifier.
    #[serde(default)]
    pub host: Option<String>,
    /// Attachment size in bytes when available.
    #[serde(default)]
    pub size: Option<u64>,
    /// Direct download URL (expires).
    #[serde(default)]
    pub download_url: Option<String>,
    /// Permanent permalink URL.
    #[serde(default)]
    pub permanent_url: Option<String>,
}
