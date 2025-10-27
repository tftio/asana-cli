# Phase 4: Attachments

**Priority**: MEDIUM
**Status**: 📋 Planned
**Estimated Effort**: 8-10 hours
**Dependencies**: None

## Overview

Implement file attachment management for tasks. Enables uploading files from local filesystem, downloading attachments, and managing task attachments.

**User Value**: "I need to attach this screenshot to the bug report" or "Download the design spec attached to this task"

## Scope

### In Scope
- List attachments on a task
- Upload file from local filesystem
- Download attachment to local filesystem
- Delete attachment
- Get attachment metadata

### Out of Scope
- Attach from URL (future enhancement)
- Attach from cloud storage (Dropbox, Google Drive)
- Image preview in terminal (future enhancement)
- Bulk upload/download
- Attachment versioning

## Asana API Endpoints

| Method | Endpoint | Purpose | Scope Required |
|--------|----------|---------|----------------|
| GET | `/attachments/{attachment_gid}` | Get attachment metadata | default |
| DELETE | `/attachments/{attachment_gid}` | Delete attachment | default |
| GET | `/tasks/{task_gid}/attachments` | List task attachments | default |
| POST | `/tasks/{task_gid}/attachments` | Upload attachment | default |

### Upload Details
- **Content-Type**: `multipart/form-data`
- **Form Fields**:
  - `file` - File data (required)
  - `name` - Optional filename override
  - `resource_subtype` - "asana" or "external"
  - `url` - For external attachments (not implemented)

## Data Models

### Extend: `src/models/attachment.rs`

Current model (already exists):
```rust
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Attachment {
    pub gid: String,
    #[serde(default)]
    pub name: Option<String>,
    #[serde(default)]
    pub resource_type: Option<String>,
    #[serde(default)]
    pub resource_subtype: Option<String>,
    #[serde(default)]
    pub created_at: Option<String>,
    #[serde(default)]
    pub download_url: Option<String>,
    #[serde(default)]
    pub permanent_url: Option<String>,
    #[serde(default)]
    pub view_url: Option<String>,
    #[serde(default)]
    pub host: Option<String>,
    #[serde(default)]
    pub parent: Option<TaskReference>,
}
```

Add:
```rust
/// Parameters for listing attachments.
#[derive(Debug, Clone)]
pub struct AttachmentListParams {
    /// Task identifier.
    pub task_gid: String,
    /// Maximum number to fetch.
    pub limit: Option<usize>,
}

/// Parameters for uploading attachments.
#[derive(Debug, Clone)]
pub struct AttachmentUploadParams {
    /// Task identifier.
    pub task_gid: String,
    /// Local file path.
    pub file_path: PathBuf,
    /// Optional filename override.
    pub name: Option<String>,
}
```

## API Operations

### File: `src/api/attachments.rs` (new)

```rust
//! High level attachment operations built on the core API client.

use crate::{
    api::{ApiClient, ApiError},
    models::{Attachment, AttachmentListParams, AttachmentUploadParams},
};
use futures_util::{pin_mut, StreamExt};
use reqwest::multipart::{Form, Part};
use serde::Deserialize;
use std::path::Path;
use tokio::fs::File;
use tokio_util::codec::{BytesCodec, FramedRead};

/// List attachments for a task.
pub async fn list_attachments(
    client: &ApiClient,
    params: AttachmentListParams,
) -> Result<Vec<Attachment>, ApiError> {
    let endpoint = format!("/tasks/{}/attachments", params.task_gid);
    let stream = client.paginate_with_limit::<Attachment>(&endpoint, vec![], params.limit);
    pin_mut!(stream);

    let mut attachments = Vec::new();
    while let Some(page) = stream.next().await {
        let mut page = page?;
        attachments.append(&mut page);
    }

    Ok(attachments)
}

/// Get a single attachment.
pub async fn get_attachment(client: &ApiClient, gid: &str) -> Result<Attachment, ApiError> {
    let response: SingleAttachmentResponse = client
        .get_json_with_pairs(&format!("/attachments/{gid}"), vec![])
        .await?;
    Ok(response.data)
}

/// Upload an attachment to a task.
pub async fn upload_attachment(
    client: &ApiClient,
    params: AttachmentUploadParams,
) -> Result<Attachment, ApiError> {
    // Read file
    let file = File::open(&params.file_path)
        .await
        .map_err(|e| ApiError::Other(format!("failed to open file: {}", e)))?;

    // Get filename
    let filename = params.name.unwrap_or_else(|| {
        params
            .file_path
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("attachment")
            .to_string()
    });

    // Create multipart form
    let stream = FramedRead::new(file, BytesCodec::new());
    let file_body = reqwest::Body::wrap_stream(stream);
    let file_part = Part::stream(file_body).file_name(filename.clone());

    let form = Form::new().part("file", file_part);

    // POST multipart form
    let endpoint = format!("/tasks/{}/attachments", params.task_gid);
    let response: SingleAttachmentResponse = client.post_multipart(&endpoint, form).await?;

    Ok(response.data)
}

/// Delete an attachment.
pub async fn delete_attachment(client: &ApiClient, gid: &str) -> Result<(), ApiError> {
    client.delete(&format!("/attachments/{gid}"), Vec::new()).await
}

/// Download an attachment to a local file.
pub async fn download_attachment(
    client: &ApiClient,
    gid: &str,
    output_path: &Path,
) -> Result<(), ApiError> {
    // Get attachment metadata to get download URL
    let attachment = get_attachment(client, gid).await?;

    let download_url = attachment
        .download_url
        .ok_or_else(|| ApiError::Other("attachment has no download URL".into()))?;

    // Download file content
    let bytes = client.download_file(&download_url).await?;

    // Write to disk
    tokio::fs::write(output_path, bytes)
        .await
        .map_err(|e| ApiError::Other(format!("failed to write file: {}", e)))?;

    Ok(())
}

#[derive(Debug, Deserialize)]
struct SingleAttachmentResponse {
    data: Attachment,
}
```

### Extend: `src/api/client.rs`

Add new methods to `ApiClient`:

```rust
impl ApiClient {
    /// POST multipart form data.
    pub async fn post_multipart<T: DeserializeOwned>(
        &self,
        path: &str,
        form: reqwest::multipart::Form,
    ) -> Result<T, ApiError> {
        let url = format!("{}{}", self.base_url, path);
        let response = self
            .http_client
            .post(&url)
            .header("Authorization", format!("Bearer {}", self.token_provider.token().expose_secret()))
            .multipart(form)
            .send()
            .await?;

        self.handle_response(response).await
    }

    /// Download file from URL.
    pub async fn download_file(&self, url: &str) -> Result<Vec<u8>, ApiError> {
        let response = self
            .http_client
            .get(url)
            .header("Authorization", format!("Bearer {}", self.token_provider.token().expose_secret()))
            .send()
            .await?;

        if !response.status().is_success() {
            return Err(ApiError::Http(response.status()));
        }

        let bytes = response.bytes().await?;
        Ok(bytes.to_vec())
    }
}
```

## CLI Commands

### Extend: `src/cli/task.rs`

Add to `TaskCommand` enum:
```rust
/// Manage task attachments.
Attachments {
    #[command(subcommand)]
    command: TaskAttachmentsCommand,
},
```

Add new subcommand enum:
```rust
#[derive(Subcommand, Debug)]
pub enum TaskAttachmentsCommand {
    /// List attachments on a task.
    List(TaskAttachmentsListArgs),
    /// Upload an attachment to a task.
    Upload(TaskAttachmentsUploadArgs),
    /// Download an attachment.
    Download(TaskAttachmentsDownloadArgs),
    /// Show attachment details.
    Show(TaskAttachmentsShowArgs),
    /// Delete an attachment.
    Delete(TaskAttachmentsDeleteArgs),
}

#[derive(Args, Debug)]
pub struct TaskAttachmentsListArgs {
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
pub struct TaskAttachmentsUploadArgs {
    /// Task identifier.
    #[arg(value_name = "TASK")]
    pub task: String,
    /// Local file path to upload.
    #[arg(long)]
    pub file: PathBuf,
    /// Override filename.
    #[arg(long)]
    pub name: Option<String>,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: TaskOutputFormat,
}

#[derive(Args, Debug)]
pub struct TaskAttachmentsDownloadArgs {
    /// Attachment identifier.
    #[arg(value_name = "ATTACHMENT")]
    pub attachment: String,
    /// Output file path.
    #[arg(long)]
    pub output: PathBuf,
    /// Overwrite existing file.
    #[arg(long)]
    pub force: bool,
}

#[derive(Args, Debug)]
pub struct TaskAttachmentsShowArgs {
    /// Attachment identifier.
    #[arg(value_name = "ATTACHMENT")]
    pub attachment: String,
    /// Output format.
    #[arg(long, value_enum, default_value = "detail")]
    pub format: TaskOutputFormat,
}

#[derive(Args, Debug)]
pub struct TaskAttachmentsDeleteArgs {
    /// Attachment identifier.
    #[arg(value_name = "ATTACHMENT")]
    pub attachment: String,
    /// Skip confirmation.
    #[arg(long)]
    pub yes: bool,
}
```

## File Changes Summary

### New Files
- `src/api/attachments.rs` (~150 lines)

### Modified Files
- `src/models/attachment.rs` - Add params structs (~30 lines)
- `src/api/client.rs` - Add post_multipart and download_file methods (~60 lines)
- `src/cli/task.rs` - Add Attachments subcommand (~250 lines)
- `src/models/mod.rs` - Export attachment params
- `src/api/mod.rs` - Export attachments module

### Dependencies to Add (Cargo.toml)
May need:
- `tokio-util` (for FramedRead) - likely already a dependency
- `mime_guess` - For detecting MIME types (optional)

## Testing Strategy

### Unit Tests
- Parameter validation
- Filename extraction logic
- Model serialization

### Integration Tests
- Mock multipart upload
- Mock file download
- List attachments pagination
- Delete attachment
- Error cases (file not found, permission denied)

### Manual Testing Checklist
- [ ] List attachments on a task
- [ ] Upload text file
- [ ] Upload image file
- [ ] Upload PDF file
- [ ] Download attachment
- [ ] Download with custom output path
- [ ] Show attachment details
- [ ] Delete attachment
- [ ] Try upload non-existent file (error)
- [ ] Try download to read-only directory (error)
- [ ] Test overwrite protection
- [ ] Test with --force flag
- [ ] Test output formats (table, json, detail)

## Example Usage

```bash
# List attachments on a task
asana-cli task attachments list 1234567890

# Upload a file
asana-cli task attachments upload 1234567890 --file ./screenshot.png

# Upload with custom name
asana-cli task attachments upload 1234567890 --file ./doc.pdf --name "Requirements Document"

# Download an attachment
asana-cli task attachments download 9876543210 --output ./downloaded.png

# Download with force overwrite
asana-cli task attachments download 9876543210 --output ./file.pdf --force

# Show attachment details
asana-cli task attachments show 9876543210

# Delete an attachment
asana-cli task attachments delete 9876543210

# Skip confirmation prompt
asana-cli task attachments delete 9876543210 --yes

# JSON output
asana-cli task attachments list 1234567890 --format json
```

## Success Criteria

- [ ] All attachment models complete
- [ ] Upload with multipart/form-data working
- [ ] Download to local files working
- [ ] List and delete operations functional
- [ ] Unit tests at 80%+ coverage
- [ ] Integration tests pass
- [ ] Clippy pedantic passes
- [ ] Manual testing complete
- [ ] Progress indicator for large uploads (nice-to-have)

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Large file upload timeout | High | Medium | Add timeout configuration, document size limits |
| Multipart form complexity | Medium | Low | Use reqwest multipart, well-tested library |
| File permission errors | Medium | Medium | Clear error messages, validate paths before upload |
| Memory usage on large files | Medium | Low | Stream file content, don't load entire file in memory |
| Download URL expiration | Low | Low | Fetch URL fresh before each download |

## Technical Considerations

### File Size Limits
- Asana API limit: 100 MB per attachment
- Client-side validation: Check file size before upload
- Progress indicators for files >1 MB (using `indicatif` crate)

### MIME Type Detection
```rust
use mime_guess;

let mime_type = mime_guess::from_path(&file_path)
    .first_or_octet_stream()
    .to_string();
```

### Streaming Upload (for large files)
```rust
use tokio::fs::File;
use tokio_util::codec::{BytesCodec, FramedRead};

let file = File::open(&path).await?;
let stream = FramedRead::new(file, BytesCodec::new());
let body = reqwest::Body::wrap_stream(stream);
```

### Progress Indicator (optional enhancement)
```rust
use indicatif::{ProgressBar, ProgressStyle};

let pb = ProgressBar::new(file_size);
pb.set_style(
    ProgressStyle::default_bar()
        .template("[{elapsed_precise}] {bar:40.cyan/blue} {bytes}/{total_bytes} {msg}")
);
```

## Error Handling

### New Error Cases
Add to `src/api/error.rs`:

```rust
pub enum ApiError {
    // ... existing variants ...

    /// File operation failed.
    FileError(String),

    /// File too large for upload.
    FileTooLarge { size: u64, max_size: u64 },

    /// Unsupported file type.
    UnsupportedFileType(String),
}
```

### Error Messages
- File not found: "Cannot upload: file not found at path/to/file"
- File too large: "File size (150 MB) exceeds Asana limit (100 MB)"
- Download failed: "Failed to download attachment: network error"
- Permission denied: "Cannot write to output path: permission denied"

## File Changes Summary

### New Files
- `src/api/attachments.rs` (~150 lines)

### Modified Files
- `src/models/attachment.rs` - Add params (~40 lines)
- `src/api/client.rs` - Add multipart methods (~60 lines)
- `src/api/error.rs` - Add file error variants (~20 lines)
- `src/cli/task.rs` - Add attachments subcommand (~300 lines)
- `src/models/mod.rs` - Export attachment params
- `src/api/mod.rs` - Export attachments module

### Dependencies (check Cargo.toml)
- `tokio-util` - For streaming file reads
- `mime_guess` - For MIME type detection (optional)
- `indicatif` - For progress bars (optional)

## Performance Optimization

### Upload Strategy
1. **Small files (<1 MB)**: Direct upload, no progress bar
2. **Medium files (1-10 MB)**: Streamed upload with progress bar
3. **Large files (>10 MB)**: Streamed upload with progress bar and chunk monitoring

### Download Strategy
1. **Stream to disk**: Don't load entire file in memory
2. **Verify checksums**: If Asana provides (future enhancement)
3. **Resume support**: Not supported by Asana API (document limitation)

## Future Enhancements

- Attach from URL (external attachments)
- Cloud storage integration (Dropbox, Google Drive)
- Image preview in terminal (using `viuer` crate)
- Bulk upload from directory
- Attachment search by name
- Download all attachments from task
- Attachment thumbnails
- Progress bar for downloads
