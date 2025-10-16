# Phase 4: Task Operations

## Explanation

Implement comprehensive task management capabilities, the core daily-use feature of the CLI. This phase adds CRUD operations for tasks, subtask management, bulk operations, and advanced features like custom fields and dependencies, making the tool a complete Asana client for terminal users.

## Rationale

Tasks are the atomic unit of work in Asana and will be the most frequently used commands. This phase needs careful attention to performance (caching, batching) and UX (fuzzy matching, shortcuts) since these operations will define the tool's daily usability. The implementation must handle the complexity of task relationships while keeping simple operations simple.

## Brief

Build the complete task command group with all CRUD operations, relationship management (subtasks, dependencies, projects), bulk operations for efficiency, custom field support, and intelligent features like fuzzy matching and natural language date parsing.

## Execution Plan (Sub-Phases)

### Phase 4a: Core Task Infrastructure
- Establish task-centric data models (`task.rs`, `custom_field.rs`, `attachment.rs`) with builders and validation.
- Wire base API endpoints (`GET/POST/PUT/DELETE /tasks`, pagination helpers).
- Implement CLI core commands: `task list`, `task show`, `task create`, `task update`, `task delete` with essential filters/sorting and consistent table/JSON output.
- Add unit/integration tests for CRUD operations and CLI flows.

### Phase 4b: Subtasks & Relationships
- Expose subtask, dependency, project, and follower endpoints.
- Add CLI subcommands: `task subtasks list/create`, `task depends-on`, `task blocks`, `task projects add/remove`, `task followers add/remove`.
- Render subtask hierarchies and dependency summaries; expand tests to cover relationship management.

### Phase 4c: Bulk & Smart Operations
- Implement batch command suite (`task create-batch`, `update-batch`, `complete-batch`) for JSON/CSV inputs.
- Deliver fuzzy matching, quick search, natural language date parsing, and recently accessed cache integration.
- Extend automated tests to exercise batch flows and matching/date parsing helpers.

### Phase 4d: Custom Fields, Tags, Comments
- Surface custom fields in outputs, support read/write/filter operations.
- Introduce tag management and comment posting/listing (with @mentions) in CLI.
- Highlight task status cues (e.g., overdue) and verify via unit/integration tests.

### Phase 4e: Performance & UX Refinement
- Tune caching/batching for high-volume task operations, including offline support.
- Polish CLI UX (TTY-aware formatting, progress indicators, optional telemetry hooks).
- Add regression/performance tests or benchmarks to validate responsiveness targets.

## TODO Checklist

- [x] Create task models:
  - [x] `src/models/task.rs` - Complete task struct
  - [x] `src/models/custom_field.rs` - Custom field types
  - [x] `src/models/attachment.rs` - File attachments
  - [x] Implement builders with validation
- [x] Add task API endpoints:
  - [x] GET `/tasks` - List tasks with filters
  - [x] GET `/tasks/{id}` - Get single task
  - [x] POST `/tasks` - Create task
  - [x] PUT `/tasks/{id}` - Update task
  - [x] DELETE `/tasks/{id}` - Delete task
  - [ ] GET `/tasks/{id}/subtasks` - List subtasks
  - [ ] POST `/tasks/{id}/addProject` - Add to project
  - [ ] POST `/tasks/{id}/addDependencies` - Set dependencies
- [ ] Implement `task list` command:
  - [x] List user's assigned tasks
  - [x] Filter by project, due date, status
  - [ ] Sort by priority, due date, created
  - [ ] Support saved views
  - [ ] Show subtask indicators
  - [ ] Highlight overdue tasks
- [ ] Implement `task show` command:
  - [x] Display complete task details
  - [ ] Show subtask hierarchy
  - [ ] Include comments and attachments
  - [x] Display custom fields
  - [x] Show dependencies graph
- [ ] Implement `task create` command:
  - [x] Quick creation with just name
  - [x] Interactive mode for details
  - [x] Assign to projects and users
  - [x] Set due dates with natural language
  - [x] Add tags and custom fields
  - [ ] Create from templates
- [ ] Implement `task update` command:
  - [x] Update any task field
  - [x] Mark complete/incomplete
  - [x] Change assignee
  - [x] Modify due dates
  - [x] Add/remove tags
  - [ ] Bulk update multiple tasks
- [ ] Implement `task complete` command:
  - [ ] Mark single task complete
  - [ ] Complete with comment
  - [ ] Recursive subtask completion
  - [ ] Fuzzy name matching
- [x] Add subtask management:
  - [x] `task subtasks list` - Show hierarchy
  - [x] `task subtasks create` - Add subtask
  - [x] `task subtasks convert` - Make subtask
- [x] Implement dependency management:
  - [x] `task depends-on` - Set dependencies
  - [x] `task blocks` - Set dependents
  - [x] `task dependencies` - View graph
- [x] Add bulk operations:
  - [x] `task create-batch` - From JSON/CSV
  - [x] `task update-batch` - Multiple updates
  - [x] `task complete-batch` - Mass completion
  - [x] Progress indicators for long operations
- [ ] Implement smart features:
  - [x] Fuzzy matching for task names
  - [x] Natural language date parsing
  - [x] Task search with relevance ranking
  - [ ] Contextual suggestions
  - [x] Recently accessed cache
- [ ] Add custom field support:
  - [ ] Display custom fields in output
  - [ ] Update custom field values
  - [ ] Filter by custom field values
  - [ ] Validate field types and constraints
- [ ] Create task templates:
  - [ ] Define template schema
  - [ ] Support field inheritance
  - [ ] Variable substitution
  - [ ] Conditional sections
- [ ] Implement comment system:
  - [ ] `task comment` - Add comment
  - [ ] `task comments` - List comments
  - [ ] Support @mentions
- [ ] Write comprehensive tests:
  - [x] Task CRUD operations
  - [x] Relationship management
  - [ ] Bulk operation handling
  - [ ] Date parsing accuracy
  - [ ] Fuzzy matching behavior

## Definition of Done

- All task operations work reliably
- Bulk operations handle 100+ tasks efficiently
- Natural language dates parse correctly
- Fuzzy matching helps users find tasks quickly
- Custom fields fully supported
- Subtasks and dependencies properly managed
- Tests cover complex scenarios
