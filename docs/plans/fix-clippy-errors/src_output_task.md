# Fix Plan: src/output/task.rs

**Total Errors**: 19

## Error Summary by Category

| Category | Count | Lines Affected |
|----------|-------|----------------|
| Redundant closures | 13 | 143, 152, 161, 170, 179, 266, 275, 284, 301, 310, 400, 405 (2x) |
| Needless borrows | 4 | 111, 122, 137, 199 |
| `map().unwrap_or_else()` | 2 | 397-401, 402-406 |
| Function too long | 1 | 107-225 |

## Detailed Errors

### 1. Function Too Long (Line 107)

**Issue**: The `render_task_detail_table` function has 116 lines, exceeding the 100-line limit.

**Function**: `render_task_detail_table(task: &Task, style: TableStyleKind) -> String`

**Fix Strategy**:
- Extract logical sections into helper functions
- Potential helpers:
  - `add_basic_fields(rows: &mut Vec, task: &Task)` - GID, name, completed, etc.
  - `add_relationship_fields(rows: &mut Vec, task: &Task)` - workspace, parent, projects
  - `add_people_fields(rows: &mut Vec, task: &Task)` - assignee, followers
  - `add_dependency_fields(rows: &mut Vec, task: &Task)` - dependencies, dependents
  - `add_custom_fields(rows: &mut Vec, task: &Task)` - custom fields if present

**Difficulty**: Medium - refactoring work, but straightforward

---

### 2. Redundant Closures (13 instances)

**Issue**: Closures that simply call a method can be replaced with method references.

**Examples**:

**Line 143**:
```rust
// Current
.map(|project| project.label())
// Fix
.map(TaskProjectReference::label)
```

**Line 152**:
```rust
// Current
.map(|tag| tag.label())
// Fix
.map(TaskTagReference::label)
```

**Line 161, 284**:
```rust
// Current
.map(|user| format_user_with_email(user))
// Fix
.map(format_user_with_email)
```

**Lines 170, 179, 301, 310**:
```rust
// Current
.map(|reference| reference.label())
// Fix
.map(TaskReference::label)
```

**Lines 266, 275, 400, 405**:
Similar patterns - replace with method/function references

**Difficulty**: Easy - direct replacement

---

### 3. Needless Borrows (4 instances)

**Issue**: Borrowing expressions that already implement the required traits.

**Line 111**:
```rust
// Current
rows.push(KeyValueRow::new("Completed", &task.completed.to_string()));
// Fix
rows.push(KeyValueRow::new("Completed", task.completed.to_string()));
```

**Line 122**:
```rust
// Current
rows.push(KeyValueRow::new("Workspace", &workspace.label()));
// Fix
rows.push(KeyValueRow::new("Workspace", workspace.label()));
```

**Line 137**:
```rust
// Current
rows.push(KeyValueRow::new("Parent", &parent.label()));
// Fix
rows.push(KeyValueRow::new("Parent", parent.label()));
```

**Line 199**:
```rust
// Current
rows.push(KeyValueRow::new(&field.name, &custom_field_display(field)));
// Fix
rows.push(KeyValueRow::new(&field.name, custom_field_display(field)));
```

**Difficulty**: Easy - remove unnecessary `&`

---

### 4. map().unwrap_or_else() Simplification (2 instances)

**Issue**: The pattern `.map(f).unwrap_or_else(g)` can be simplified to `.map_or_else(g, f)`.

**Lines 397-401**:
```rust
// Current
assignee: task
    .assignee
    .as_ref()
    .map(|user| user.label())
    .unwrap_or_else(|| "-".into()),

// Fix
assignee: task
    .assignee
    .as_ref()
    .map_or_else(|| "-".into(), UserReference::label),
```

**Lines 402-406**:
```rust
// Current
project: task
    .projects
    .first()
    .map(|project| project.label())
    .unwrap_or_else(|| "-".into()),

// Fix
project: task
    .projects
    .first()
    .map_or_else(|| "-".into(), TaskProjectReference::label),
```

**Difficulty**: Easy - pattern replacement

---

## Fix Order Recommendation

1. **Phase 1 - Easy Fixes (Can be automated)**:
   - Remove needless borrows (4)
   - Replace redundant closures (13)
   - Simplify `map().unwrap_or_else()` (2)

2. **Phase 2 - Function Refactoring**:
   - Extract helper functions to reduce `render_task_detail_table` length (1)

## Testing Notes

- After fixes, verify task detail rendering is unchanged
- Test with tasks that have:
  - All fields populated
  - Minimal fields (optional fields missing)
  - Custom fields
  - Multiple projects, tags, followers
  - Dependencies/dependents
- Check both table output formats if applicable
