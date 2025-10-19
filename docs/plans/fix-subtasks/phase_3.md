# Phase 3: Testing and Validation

## Explanation

This phase focuses on comprehensive testing to ensure the subtask fetching implementation works correctly across all scenarios, including edge cases, and that existing functionality remains intact.

We'll add integration tests, validate with real API data, and ensure backward compatibility.

## Rationale

### Why Dedicated Testing Phase?
The subtask functionality is complex with multiple failure modes:
- API errors during subtask fetch
- Date filtering logic across parent and subtask tasks
- Permission issues
- Performance with many parents

A dedicated testing phase ensures we catch issues before they reach users.

### Why Integration Tests?
Unit tests can't validate the actual API interaction and field population. Integration tests with real API calls (or mocked realistic responses) are necessary to verify the fix works end-to-end.

### Why Backward Compatibility Testing?
The changes affect core task listing functionality. We must ensure tasks without subtasks, existing date filters, and other features continue working exactly as before.

## Brief

Create comprehensive tests covering subtask date filtering, validate with real API data (including test task 1211675035613186), ensure all existing tests pass, and document any limitations or known issues.

## Implementation Checklist

### Integration Tests - tests/cli.rs or new file

- [ ] Add test for subtasks with date filtering:
  ```rust
  #[tokio::test]
  async fn test_subtasks_with_due_after_filter() {
      // Test that subtasks with due dates are included in filtered results
      // Use real API or mock response with subtask data
  }
  ```

- [ ] Add test for specific subtask (1211675035613186):
  ```rust
  #[tokio::test]
  async fn test_known_subtask_with_due_date() {
      // Fetch task 1211675035613186
      // Verify due_on = "2025-10-20"
      // Verify it appears in --due-after "2025-10-01" results
  }
  ```

- [ ] Add test for combined filters:
  ```rust
  #[tokio::test]
  async fn test_subtasks_with_due_range_filter() {
      // Test --due-after and --due-before together
      // Verify subtasks within range are included
  }
  ```

- [ ] Add test for tasks without subtasks:
  ```rust
  #[tokio::test]
  async fn test_no_subtasks_unchanged_behavior() {
      // Verify tasks without subtasks work as before
      // No regression in existing functionality
  }
  ```

- [ ] Add test for error handling:
  ```rust
  #[tokio::test]
  async fn test_subtask_fetch_failure_handling() {
      // Mock API failure during subtask fetch
      // Verify graceful error handling
  }
  ```

### Unit Tests - src/models/task.rs

- [ ] Update `blank_task_for_test()` helper to include `num_subtasks: None`

- [ ] Add test for Task with num_subtasks field:
  ```rust
  #[test]
  fn test_task_with_num_subtasks() {
      // Verify deserialization of num_subtasks field
  }
  ```

### Regression Testing

- [x] completed: Run full test suite: `cargo test --all --verbose`
- [x] completed: Verify all existing unit tests still pass (31 tests)
- [x] completed: Verify all existing integration tests still pass (4 tests)
- [x] completed: Verify all existing CLI tests still pass (23 tests)
- [x] completed: Document total test count (58 tests passed)

### Manual Testing Checklist

- [ ] Test with real Asana account:
  ```bash
  asana-cli task list --include-subtasks --limit 10
  ```

- [ ] Test date filtering on subtasks:
  ```bash
  asana-cli task list --include-subtasks --due-after "2025-10-01"
  ```

- [ ] Test specific subtask fetch:
  ```bash
  asana-cli task show 1211675035613186
  ```

- [ ] Test without subtasks flag (ensure no change):
  ```bash
  asana-cli task list --limit 10
  ```

- [ ] Test with completion filter:
  ```bash
  asana-cli task list --include-subtasks --completed false
  ```

- [ ] Test with multiple filters combined:
  ```bash
  asana-cli task list --include-subtasks --due-after "2025-10-01" --due-before "2025-11-01" --completed false
  ```

### Performance Testing

- [ ] Measure API call count with 10 parent tasks (5 with subtasks)
- [ ] Verify rate limiting is not exceeded
- [ ] Document expected performance in code comments
- [ ] Consider adding progress indicator if > 10 subtask fetches

### Documentation Updates

- [ ] Update CLI help text if needed
- [ ] Add comment in code explaining the subtask fetching approach
- [ ] Document known limitations (e.g., nested subtasks behavior)
- [ ] Update CHANGELOG.md with fix description

## Expected Outcome

After Phase 3:
- All tests pass (existing + new integration tests)
- Subtask date filtering works correctly with real API data
- No regressions in existing functionality
- Performance is acceptable and documented
- Code is well-documented with comments explaining the approach
- Known limitations are documented

## Test Data Requirements

For integration tests, you'll need:
- A test Asana workspace with projects
- Parent tasks with and without subtasks
- Subtasks with various due dates (past, present, future)
- Mix of `due_on` and `due_at` dates
- The specific test subtask: 1211675035613186 (due_on: "2025-10-20")

## Known Limitations to Document

- [ ] Nested subtasks (subtasks of subtasks) - document behavior
- [ ] Performance with 100+ parent tasks with subtasks
- [ ] Rate limiting considerations (1500 req/min for premium)
- [ ] Requires separate API call per parent with subtasks

## Files Changed

1. **tests/cli.rs** (or new test file) - Add integration tests
2. **src/models/task.rs** - Update test helpers
3. **docs/CHANGELOG.md** (if exists) - Document the fix

## Success Criteria

- [ ] All tests pass without errors or warnings
- [ ] Manual testing confirms subtasks have complete date fields
- [ ] Date filters work correctly on both parent tasks and subtasks
- [ ] No performance degradation for normal use cases (< 20 parents with subtasks)
- [ ] Error handling is graceful and informative
- [ ] Code is well-documented and maintainable
- [ ] Changes are backward compatible (no breaking changes)

## Rollback Plan

If critical issues are discovered:
1. Revert Phase 2 changes (subtask fetching logic)
2. Optionally revert Phase 1 (restore opt_expand parameter)
3. Document the issue for future investigation
4. Consider alternative approaches (e.g., client-side date filtering only)
