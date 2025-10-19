# Phase 1: Remove Deprecated API Usage

## Explanation

This phase removes the deprecated `opt_expand=subtasks` API parameter from the request building logic. The `opt_expand` parameter no longer returns full field data for subtasks per Asana's API deprecation.

We'll keep the `include_subtasks` boolean flag in `TaskListParams` as it controls whether we should fetch subtasks at all. However, we'll stop passing it to the API as `opt_expand=subtasks`.

Additionally, we'll add `num_subtasks` to the default fields so we can detect which tasks have subtasks in Phase 2.

## Rationale

### Why Remove opt_expand?
The Asana API documentation and forum posts confirm that `opt_expand=subtasks` is deprecated and no longer populates subtask fields correctly. Continuing to use it provides no value and creates confusion.

### Why Keep include_subtasks Flag?
The `include_subtasks` boolean in `TaskListParams` serves as a user-facing control that determines whether subtasks should be fetched. In Phase 2, we'll use this flag to decide whether to make separate subtask API calls.

### Why Add num_subtasks?
The `num_subtasks` field tells us which tasks have subtasks without having to fetch all subtasks upfront. This enables efficient conditional fetching in Phase 2.

## Brief

Remove the deprecated `opt_expand=subtasks` parameter from API requests while preserving the `include_subtasks` user control. Add `num_subtasks` to the default field set for future subtask detection.

## Implementation Checklist

### src/models/task.rs

- [x] completed: Remove lines 294-296 in `to_query()` method
- [x] completed: Add comment explaining that `include_subtasks` now controls separate subtask fetching
- [x] completed: Verify `include_subtasks` field remains in `TaskListParams` struct (line 253)

### src/api/tasks.rs

- [x] completed: Add `"num_subtasks"` to the `defaults` array in `ensure_default_fields()` (around line 376)
- [x] completed: Position it logically (near other count/metadata fields)
- [x] completed: Update function documentation if needed
- [x] completed: Remove the subtask field prefixing logic added earlier (lines 407-413) since it doesn't work with deprecated opt_expand

### Testing

- [x] completed: Run `cargo test --all` to ensure no immediate breakage (31 tests passed)
- [x] completed: Run `cargo build --release` to verify compilation
- [x] completed: Note: Subtask functionality will be temporarily broken (expected)

## Expected Outcome

After Phase 1:
- Code compiles without errors or warnings
- `opt_expand=subtasks` is no longer sent to Asana API
- `num_subtasks` field is requested in all task listings
- All existing tests pass (non-subtask tests should be unaffected)
- Subtask functionality is temporarily non-functional (will be restored in Phase 2)

## Files Changed

1. **src/models/task.rs** - Remove deprecated API parameter usage
2. **src/api/tasks.rs** - Add num_subtasks to default fields, remove subtask field prefixing

## Rollback Plan

If Phase 1 causes unexpected issues, revert the simple changes:
1. Re-add the `opt_expand=subtasks` code block
2. Remove `num_subtasks` from defaults array
3. Re-add subtask field prefixing logic

The changes are minimal and easily reversible.
