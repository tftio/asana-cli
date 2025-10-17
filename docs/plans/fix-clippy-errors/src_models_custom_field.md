# Fix Plan: src/models/custom_field.rs

**Total Errors**: 1

## Error Summary by Category

| Category | Count | Lines Affected |
|----------|-------|----------------|
| `map().unwrap_or()` simplification | 1 | 156-158 |

## Detailed Error

### 1. map().unwrap_or() Simplification (Lines 156-158)

**Issue**: Using `.map(f).unwrap_or(default)` when `.map_or(default, f)` is more efficient and idiomatic.

**Current**:
```rust
Self::Number(value) => serde_json::Number::from_f64(value)
    .map(Value::Number)
    .unwrap_or(Value::Null),
```

**Fix**:
```rust
Self::Number(value) => serde_json::Number::from_f64(value)
    .map_or(Value::Null, Value::Number),
```

**Explanation**:
- `map_or` is more efficient because it only evaluates the default value if needed
- The argument order is `map_or(default, mapper)` which is reversed from `map(mapper).unwrap_or(default)`
- This is handling the case where `from_f64` returns `None` for non-finite floats (NaN, infinity)

**Context**: This appears to be in a conversion from a custom field value type to a JSON value.

**Difficulty**: Easy - straightforward pattern replacement

---

## Testing Notes

- Test custom field conversion with:
  - Normal numeric values
  - Zero
  - Negative numbers
  - Very large numbers
  - Edge cases that might result in `None` from `from_f64` (though this should be rare in practice)
- Verify JSON serialization produces expected output
