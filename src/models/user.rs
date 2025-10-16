//! User-centric data structures consumed by the CLI.

use super::project::MemberPermission;
use serde::{Deserialize, Serialize};

/// Lightweight user reference returned by Asana APIs.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct UserReference {
    /// Globally unique identifier.
    pub gid: String,
    /// Human friendly display name.
    #[serde(default)]
    pub name: Option<String>,
    /// Resource type reported by Asana.
    #[serde(default)]
    pub resource_type: Option<String>,
    /// Optional primary email address when included in the response.
    #[serde(default)]
    pub email: Option<String>,
}

impl UserReference {
    /// Convenience helper displaying either the name or email.
    #[must_use]
    pub fn label(&self) -> String {
        self.name
            .clone()
            .or_else(|| self.email.clone())
            .unwrap_or_else(|| self.gid.clone())
    }
}

/// Identity payload used when specifying members in API requests.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct UserIdentity {
    /// Accept both email addresses and gids per Asana API contract.
    pub resource: String,
    /// Optional role/permission hint.
    #[serde(default)]
    pub role: Option<MemberPermission>,
}
