//! Workspace and team references.

use serde::{Deserialize, Serialize};

/// Lightweight workspace reference.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct WorkspaceReference {
    /// Globally unique identifier.
    pub gid: String,
    /// Optional display name.
    #[serde(default)]
    pub name: Option<String>,
    /// Optional resource type marker from Asana.
    #[serde(default)]
    pub resource_type: Option<String>,
}

impl WorkspaceReference {
    /// Display helper returning a human readable label.
    #[must_use]
    pub fn label(&self) -> String {
        self.name.clone().unwrap_or_else(|| self.gid.clone())
    }
}
