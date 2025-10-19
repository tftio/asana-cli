# Phase 2: Implement Separate Subtask Fetching

## Explanation

This phase implements the core fix: fetching subtasks via separate API calls to `/tasks/{gid}/subtasks` for each parent task that has subtasks.

The approach:
1. After pagination completes in `list_tasks()`, examine the `num_subtasks` field
2. For each task where `num_subtasks > 0`, call the existing `list_subtasks()` function
3. Merge the returned subtasks into the main task list
4. Ensure proper field selection is passed to subtask requests

## Rationale

### Why Separate API Calls?
Asana's recommended pattern for fetching subtasks with full field data is to use the dedicated `/tasks/{gid}/subtasks` endpoint. This is the only reliable way to get complete field information.

### Why Reuse list_subtasks()?
The `list_subtasks()` function (src/api/tasks.rs:109-132) already exists and handles:
- Field specification via `opt_fields`
- Pagination for tasks with many subtasks
- Proper error handling

Reusing it maintains consistency and avoids code duplication.

### Why Merge Before Post-Filters?
Post-filters (`due_after`, `due_before`, `completed`) should apply to both parent tasks and subtasks uniformly. By merging before filtering, we ensure consistent behavior.

### Performance Considerations
This approach makes N additional API calls where N = number of parent tasks with subtasks. For typical usage (10-50 tasks with 10-30% having subtasks), this adds 1-15 API calls. Given Asana's rate limits (1500 requests/minute for premium), this is acceptable.

If performance becomes an issue, we can:
- Add a configuration option to disable subtask fetching
- Implement batch fetching if Asana adds that capability
- Cache subtask results

## Brief

Modify `list_tasks()` to detect parent tasks with subtasks (via `num_subtasks` field), fetch subtasks separately using the existing `list_subtasks()` function, and merge them into the result list before applying post-filters.

## Implementation Checklist

### src/api/tasks.rs - Modify list_tasks()

- [x] completed: After pagination loop completes (around line 31), add logic to fetch subtasks
  ```rust
  // Fetch subtasks if requested
  if params.include_subtasks {
      let mut all_subtasks = Vec::new();
      for task in &tasks {
          if task.num_subtasks.unwrap_or(0) > 0 {
              let subtasks = list_subtasks(
                  client,
                  &task.gid,
                  params.fields.iter().cloned().collect()
              ).await?;
              all_subtasks.extend(subtasks);
          }
      }
      tasks.extend(all_subtasks);
  }
  ```

- [x] completed: Ensure this happens BEFORE `params.apply_post_filters(&mut tasks)` (line 33)
- [x] completed: Add error handling for subtask fetching failures (using .await?)
- [x] completed: Add documentation comment explaining the approach

### src/models/task.rs - Add num_subtasks field

- [x] completed: Add `num_subtasks` field to Task struct (around line 225)
- [x] completed: Update the test helper `blank_task()` in cli/task.rs to include `num_subtasks: None`

### src/api/tasks.rs - Update ensure_subtask_fields()

- [x] completed: Review `ensure_subtask_fields()` function (lines 409-416)
- [x] completed: Consider whether default fields need adjustment (passing same fields as parent)
- [x] completed: Ensure it matches the fields used in parent task requests

### Testing During Development

- [x] completed: Test with a known parent task that has subtasks (via cargo test)
- [x] completed: Verify field data is populated correctly
- [x] completed: Check that error handling works (propagates via .await?)

## Expected Outcome

After Phase 2:
- Subtasks are fetched with complete field data (including `due_on`, `due_at`)
- The result list contains both parent tasks and their subtasks
- Post-filters apply to all tasks uniformly
- Performance is acceptable for typical use cases (1-15 additional API calls)
- Error handling gracefully manages subtask fetch failures

## Test Cases for Manual Verification

Before moving to Phase 3, manually test:

1. **Basic subtask fetch**:
   ```bash
   asana-cli task list --include-subtasks --limit 10
   ```
   Verify subtasks appear with full fields

2. **Date filter on subtasks**:
   ```bash
   asana-cli task list --include-subtasks --due-after "2025-10-01"
   ```
   Verify subtasks with due dates are included

3. **Specific test subtask**:
   ```bash
   asana-cli task show 1211675035613186
   ```
   Verify due_on field is "2025-10-20"

4. **No subtasks case**:
   ```bash
   asana-cli task list --limit 10
   ```
   Verify no errors, normal behavior without --include-subtasks

## Files Changed

1. **src/api/tasks.rs** - Modify `list_tasks()` to fetch subtasks separately
2. **src/models/task.rs** - Add `num_subtasks` field to Task struct

## Edge Cases to Consider

- [ ] Task has `num_subtasks > 0` but subtask fetch fails (network error)
- [ ] Task has `num_subtasks > 0` but subtasks were deleted (returns empty list)
- [ ] Pagination needed for subtasks (many subtasks on one parent)
- [ ] User doesn't have permission to view subtasks
- [ ] Subtask itself has subtasks (nested subtasks - document behavior)

## Performance Notes

Document in code comments:
- This approach makes O(N) additional API calls where N = parent tasks with subtasks
- Trade-off: Correctness and complete field data vs. additional API calls
- Asana rate limit: 1500 requests/minute (premium) - acceptable for typical usage
- Alternative considered: Single API call with opt_expand (deprecated, doesn't work)
