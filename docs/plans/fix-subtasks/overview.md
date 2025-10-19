# Fix Subtasks Date Field Filtering

## Overview

The `--include-subtasks` flag in the asana-cli tool fails to return date fields (`due_on`, `due_at`) for subtasks, causing date filters (`--due-after`, `--due-before`) to incorrectly exclude subtasks from results.

## Problem Statement

When users run commands like:
```bash
asana-cli task list --include-subtasks --due-after "2025-10-01"
```

Subtasks with due dates after the specified date are excluded from results because the date fields are not populated in the API response.

## Root Cause

The implementation uses Asana's **deprecated** `opt_expand=subtasks` API parameter (src/models/task.rs:295):

```rust
if self.include_subtasks {
    pairs.push(("opt_expand".into(), "subtasks".into()));
}
```

According to Asana API forum discussions, `opt_expand=subtasks` is deprecated and no longer returns full field data. The `subtasks.*` prefixed fields in `opt_fields` don't work with the deprecated parameter.

## Recommended Solution

Replace the deprecated approach with Asana's recommended pattern:

1. Add `num_subtasks` field to default field requests
2. Remove `opt_expand=subtasks` usage
3. After fetching parent tasks, detect tasks with `num_subtasks > 0`
4. Make separate API calls to `/tasks/{gid}/subtasks` for each parent task
5. Merge subtasks into the result list
6. Apply post-filters (`due_after`, `due_before`) to combined list

## Current Status

**State**: All Phases Complete - Implementation Ready for Manual Testing

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 | COMPLETED | Remove deprecated API usage |
| Phase 2 | COMPLETED | Implement separate subtask fetching |
| Phase 3 | COMPLETED | Testing and validation |

## Files to be Modified

1. **src/models/task.rs** (~1205 lines)
   - Remove `opt_expand=subtasks` logic from `to_query()` (line 295)
   - Keep `include_subtasks` flag for control flow
   - Add `num_subtasks` field to Task struct

2. **src/api/tasks.rs** (~543 lines)
   - Modify `list_tasks()` function (lines 16-40)
   - Add `num_subtasks` to `ensure_default_fields()` (lines 375-414)
   - Implement subtask fetching logic after pagination
   - Call existing `list_subtasks()` function (lines 109-132)
   - Merge subtasks into result list before post-filters

3. **tests/** (if needed)
   - Update integration tests if assertions change
   - Add new test for subtask date filtering

## Testing Requirements

### Test Cases
1. **Basic subtask retrieval**: Verify subtasks are returned with full fields
2. **Date filter on subtasks**: Test with task 1211675035613186 (due_on: "2025-10-20")
3. **Due-after filter**: `--include-subtasks --due-after "2025-10-01"` returns subtasks
4. **Due-before filter**: `--include-subtasks --due-before "2025-11-01"` returns subtasks
5. **Combined filters**: Test with both due_after and due_before
6. **No subtasks case**: Verify tasks without subtasks work as before
7. **Mixed case**: Parents and subtasks both matching filter criteria

### Regression Tests
- Ensure all existing tests still pass
- Verify non-subtask functionality unchanged
- Test performance with many parent tasks

## Implementation Notes

### API Call Considerations
- The `list_subtasks()` function already exists in src/api/tasks.rs (lines 109-132)
- It supports field specification and pagination
- Reuse this function for consistency

### Performance Considerations
- Multiple API calls will be made (one per parent task with subtasks)
- Consider batching or limiting if performance becomes an issue
- Document the tradeoff in code comments

### Field Management
- Ensure subtask fields match parent task fields for consistent filtering
- The existing `ensure_subtask_fields()` function (lines 409-416) may need updates
- Pass the same field set used for parents to subtask requests

## External References

- Asana API Forum: Discussion on deprecated opt_expand parameter (https://forum.asana.com/t/the-subtasks-field-on-tasks-is-being-deprecated/44548)
- Asana API Docs: `/tasks/{gid}/subtasks` endpoint
- Test subtask GID: 1211675035613186 (due_on: "2025-10-20")

## Dependencies

None - all changes are internal to the asana-cli codebase.

## Success Criteria

- [x] completed: Subtasks are returned with complete date fields (via separate API calls)
- [x] completed: Date filters work correctly on subtasks (applied after merging)
- [x] completed: All existing tests pass (58 tests: 31 unit + 4 integration + 23 CLI)
- [x] completed: No breaking changes to CLI interface (backward compatible)
- [x] completed: Performance is acceptable for typical use cases (O(N) API calls where N = parents with subtasks)
- [ ] Manual testing with real Asana data (ready for user validation)

## Phase Documents

- [Phase 1: Remove Deprecated API Usage](./phase_1.md)
- [Phase 2: Implement Separate Subtask Fetching](./phase_2.md)
- [Phase 3: Testing and Validation](./phase_3.md)
