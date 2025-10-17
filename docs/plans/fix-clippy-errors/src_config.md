# Fix Plan: src/config.rs

**Total Errors**: 4

## Error Summary by Category

| Category | Count | Lines Affected |
|----------|-------|----------------|
| Missing `# Errors` documentation | 3 | 152, 167, 182 |
| Unnecessary Result wrapper | 1 | 229 |

## Detailed Errors

### 1. Missing `# Errors` Documentation (Lines 152, 167, 182)

**Issue**: Public functions returning `Result` must document when they return errors.

**Line 152 - `set_default_workspace`**:
```rust
pub fn set_default_workspace(&mut self, workspace: Option<String>) -> Result<()> {
```

**Fix**: Add documentation:
```rust
/// Sets the default workspace identifier.
///
/// # Errors
///
/// Returns an error if the configuration file cannot be saved to disk.
pub fn set_default_workspace(&mut self, workspace: Option<String>) -> Result<()> {
```

---

**Line 167 - `set_default_assignee`**:
```rust
pub fn set_default_assignee(&mut self, assignee: Option<String>) -> Result<()> {
```

**Fix**: Add documentation:
```rust
/// Sets the default assignee identifier.
///
/// # Errors
///
/// Returns an error if the configuration file cannot be saved to disk.
pub fn set_default_assignee(&mut self, assignee: Option<String>) -> Result<()> {
```

---

**Line 182 - `set_default_project`**:
```rust
pub fn set_default_project(&mut self, project: Option<String>) -> Result<()> {
```

**Fix**: Add documentation:
```rust
/// Sets the default project identifier.
///
/// # Errors
///
/// Returns an error if the configuration file cannot be saved to disk.
pub fn set_default_project(&mut self, project: Option<String>) -> Result<()> {
```

**Difficulty**: Easy - documentation addition

---

### 2. Unnecessary Result Wrapper (Line 229)

**Issue**: The `personal_access_token()` function returns `Result<Option<SecretString>>` but never actually returns an `Err` variant.

**Current**:
```rust
pub fn personal_access_token(&self) -> Result<Option<SecretString>> {
    if let Some(token) = self.overrides.personal_access_token.clone() {
        return Ok(Some(token));
    }
    Ok(self.file.personal_access_token.as_ref().and_then(|value| {
        if value.trim().is_empty() {
            None
        } else {
            Some(SecretString::new(value.clone()))
        }
    }))
}
```

**Fix**: Change return type to `Option<SecretString>` and remove `Ok()` wrappers:
```rust
pub fn personal_access_token(&self) -> Option<SecretString> {
    if let Some(token) = self.overrides.personal_access_token.clone() {
        return Some(token);
    }
    self.file.personal_access_token.as_ref().and_then(|value| {
        if value.trim().is_empty() {
            None
        } else {
            Some(SecretString::new(value.clone()))
        }
    })
}
```

**Impact**: This will require updating all call sites that use this function.

**Call sites to update** (likely in):
- `src/cli/mod.rs` - `handle_config_get()` and `build_api_client()`
- Possibly other locations

**Current usage pattern**:
```rust
match config.personal_access_token()? {
    Some(token) => { /* use token */ }
    None => { /* handle missing token */ }
}
```

**New usage pattern**:
```rust
match config.personal_access_token() {
    Some(token) => { /* use token */ }
    None => { /* handle missing token */ }
}
```

**Difficulty**: Medium
- Requires updating all call sites
- Need to verify error handling at call sites still works
- The `?` operator will need to be removed from call sites

---

## Fix Order Recommendation

1. **Phase 1 - Documentation**:
   - Add `# Errors` sections to three setter functions (easy)

2. **Phase 2 - API Change**:
   - Remove unnecessary `Result` wrapper from `personal_access_token()` (medium)
   - Update all call sites

## Call Site Investigation Needed

Before fixing the `personal_access_token()` function, search for all usages:

```bash
rg "personal_access_token\(\)" --type rust
```

Expected locations:
- `src/cli/mod.rs::handle_config_get()` - displays token status
- `src/cli/mod.rs::build_api_client()` - retrieves token for API client

---

## Testing Notes

- After documentation fixes: Verify docs generate correctly with `cargo doc`
- After Result removal:
  - Verify config get command works
  - Verify API client initialization works
  - Test both with and without tokens configured
  - Test with token from environment vs file
  - Ensure error messages for missing tokens remain clear
