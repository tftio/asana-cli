# Fix Plan: src/api/tasks.rs

**Total Errors**: 3

## Error Summary by Category

| Category | Count | Lines Affected |
|----------|-------|----------------|
| Inefficient to_string | 1 | 54 |
| Unnecessary sort_by | 1 | 432 |
| Redundant closure | 1 | 437 |

## Detailed Errors

### 1. Inefficient to_string (Line 54)

**Issue**: Calling `to_string()` on `&&str` uses a slower blanket implementation instead of the fast specialization.

**Current**:
```rust
field_set.insert(field.to_string());
```

**Fix**:
```rust
field_set.insert((*field).to_string());
```

**Explanation**: When you have `&&str`, calling `.to_string()` resolves to a generic trait implementation. Dereferencing first (`*field`) gives you `&str`, which has an optimized `to_string()` implementation.

**Difficulty**: Easy - add dereference operator

---

### 2. Unnecessary sort_by (Line 432)

**Issue**: Using `sort_by` with a simple key function when `sort_by_key` is more idiomatic and potentially more efficient.

**Current**:
```rust
TaskSort::Assignee => tasks.sort_by(|a, b| assignee_label(a).cmp(&assignee_label(b))),
```

**Fix**:
```rust
TaskSort::Assignee => tasks.sort_by_key(|a| assignee_label(a)),
```

**Explanation**: `sort_by_key` is more efficient because it calls the key function once per element, whereas `sort_by` with a comparison might call it multiple times per element.

**Difficulty**: Easy - use sort_by_key instead

---

### 3. Redundant Closure (Line 437)

**Issue**: Using a closure that just calls a method, when the method reference can be used directly.

**Current**:
```rust
task.assignee.as_ref().map(|assignee| assignee.label())
```

**Fix**:
```rust
task.assignee.as_ref().map(UserReference::label)
```

**Difficulty**: Easy - replace closure with method reference

---

## Fix Order Recommendation

All three fixes are independent and easy:

1. Fix inefficient to_string (line 54)
2. Fix unnecessary sort_by (line 432)
3. Fix redundant closure (line 437)

## Testing Notes

- Test field set insertion works correctly
- Test task sorting by assignee produces correct order
- Verify assignee label display is unchanged
