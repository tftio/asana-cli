# Fix Plan: src/models/task.rs

**Total Errors**: 12

## Error Summary by Category

| Category | Count | Lines Affected |
|----------|-------|----------------|
| `Option<Option<T>>` patterns | 8 | 587, 590, 596, 599, 602, 605, 608, 611 |
| `map_or` simplification | 2 | 331, 334 |
| Derivable impl | 1 | 268 |
| Needless pass by value | 1 | 858 (referenced from cli/task.rs:1699) |

## Detailed Errors

### 1. Option<Option<T>> Pattern (8 instances)

**Issue**: Fields in what appears to be a task update struct use `Option<Option<T>>`, which is typically an anti-pattern.

**Affected Fields (Lines 587-611)**:
- `notes: Option<Option<String>>`
- `html_notes: Option<Option<String>>`
- `assignee: Option<Option<String>>`
- `due_on: Option<Option<String>>`
- `due_at: Option<Option<String>>`
- `start_on: Option<Option<String>>`
- `start_at: Option<Option<String>>`
- `parent: Option<Option<String>>`

**Context**: This appears to be in a task update/modification structure.

**Why Option<Option<T>>?**
The pattern `Option<Option<T>>` is likely used to distinguish three states:
1. `None` - Field not being updated (omit from API request)
2. `Some(None)` - Clear/unset the field (send null to API)
3. `Some(Some(value))` - Set field to specific value

**Fix Options**:

**Option A - Custom Enum (Recommended)**:
```rust
pub enum FieldUpdate<T> {
    Unchanged,     // Don't include in update
    Clear,         // Set to null
    Set(T),        // Set to value
}
```

Then use: `pub notes: FieldUpdate<String>`

**Option B - Keep Pattern, Suppress Warning**:
If the three-state distinction is truly needed and no better alternative exists:
```rust
#[allow(clippy::option_option)]
pub notes: Option<Option<String>>,
```

**Option C - Flatten with Sentinel**:
Use a special value or wrapper type to represent "clear" vs "not set"

**Difficulty**: High
- Requires careful API design consideration
- Affects serialization logic
- May impact existing code that constructs updates
- Need to verify how Asana API handles field updates

---

### 2. map_or Simplification (Lines 331, 334)

**Issue**: Using `.map_or(false, |x| predicate)` when `.is_some_and(|x| predicate)` is clearer.

**Line 331**:
```rust
// Current
tasks.retain(|task| task.due_on.as_ref().map_or(false, |due| due <= due_before));

// Fix
tasks.retain(|task| task.due_on.as_ref().is_some_and(|due| due <= due_before));
```

**Line 334**:
```rust
// Current
tasks.retain(|task| task.due_on.as_ref().map_or(false, |due| due >= due_after));

// Fix
tasks.retain(|task| task.due_on.as_ref().is_some_and(|due| due >= due_after));
```

**Difficulty**: Easy - direct replacement

---

### 3. Derivable Default Implementation (Line 268)

**Issue**: The `Default` impl for `TaskListParams` can be automatically derived.

**Current**:
```rust
impl Default for TaskListParams {
    fn default() -> Self {
        Self {
            workspace: None,
            // ... all None/default values
        }
    }
}
```

**Fix**:
```rust
#[derive(Default)]
pub struct TaskListParams {
    // fields...
}
```

**Difficulty**: Easy - replace impl with derive attribute

---

### 4. Needless Pass by Value (Line 858, used at cli/task.rs:1699)

**Issue**: `TaskValidationError` is passed by value but not consumed.

**Location**: Enum defined at line 858, used in `src/cli/task.rs:1699`

**Current** (in cli/task.rs):
```rust
fn map_validation_error(err: TaskValidationError, context: &str) -> anyhow::Error {
```

**Fix Option A** - Take reference:
```rust
fn map_validation_error(err: &TaskValidationError, context: &str) -> anyhow::Error {
```

**Fix Option B** - Make enum `Copy`:
```rust
#[derive(Debug, Clone, Copy, ...)]
pub enum TaskValidationError {
    // variants...
}
```

**Difficulty**: Easy-Medium
- Need to verify enum size (should be small for Copy)
- Update call sites if using reference approach
- Check if enum is used elsewhere

---

## Fix Order Recommendation

1. **Phase 1 - Easy Fixes**:
   - `map_or` simplification (2)
   - Derivable Default impl (1)
   - Needless pass by value (1)

2. **Phase 2 - API Design Review**:
   - `Option<Option<T>>` patterns (8) - **Requires design decision**

## Design Discussion Required

### Option<Option<T>> Pattern

This requires a decision on API design:

**Question**: Do we need to distinguish between "don't update field" vs "clear field"?

If YES → Use custom `FieldUpdate<T>` enum (cleaner, more explicit)
If NO → Can flatten to `Option<T>` (simpler, but may lose functionality)

**Action Items**:
1. Review Asana API documentation for update semantics
2. Check if partial updates are supported
3. Verify how field clearing works in the API
4. Review existing code that builds update requests
5. Make decision on appropriate abstraction

## Testing Notes

- Test task update operations:
  - Partial updates (some fields changed)
  - Clearing optional fields
  - Setting previously empty fields
- Verify date filtering logic after `map_or` changes
- Ensure Default derivation produces same values
