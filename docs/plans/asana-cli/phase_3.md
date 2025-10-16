# Phase 3: Project Operations

## Explanation

Implement complete CRUD operations for Asana projects, including listing, viewing, creating, updating, and managing project membership. This phase delivers the first user-facing functionality, allowing users to manage their projects entirely from the command line.

## Rationale

Projects are the primary organizational unit in Asana, making them the logical starting point for user features. Project operations are typically less frequent than task operations, making them ideal for validating our API patterns before moving to higher-volume task operations. This phase also establishes UX patterns for table output, JSON formatting, and interactive prompts.

## Brief

Build the project command group with subcommands for list, show, create, update, delete, and member management. Implement multiple output formats (table, JSON, CSV), filtering and sorting options, and template support for project creation.

## TODO Checklist

- [x] Create project models:
  - [x] `src/models/project.rs` - Project struct with serde
  - [x] `src/models/workspace.rs` - Workspace struct
  - [x] `src/models/user.rs` - User/Member structs
  - [x] Implement builders for create/update
- [x] Add project API endpoints:
  - [x] GET `/projects` - List projects
  - [x] GET `/projects/{id}` - Get single project
  - [x] POST `/projects` - Create project
  - [x] PUT `/projects/{id}` - Update project
  - [x] DELETE `/projects/{id}` - Delete project
  - [x] GET `/projects/{id}/members` - List members
- [x] Implement `project list` command:
  - [x] Basic listing with pagination
  - [x] Filter by workspace, team, archived status
  - [x] Sort by name, created, modified
  - [x] Table output with configurable columns
  - [x] JSON output for scripting
  - [x] CSV export option
- [x] Implement `project show` command:
  - [x] Fetch project details by ID or name
  - [x] Display all fields in readable format
  - [x] Show member list and roles
  - [x] Include recent status updates
  - [x] Support JSON output
- [x] Implement `project create` command:
  - [x] Interactive mode with prompts
  - [x] Flag-based creation
  - [x] Template support from TOML files
  - [x] Set initial members and permissions
  - [x] Return project URL on success
- [x] Implement `project update` command:
  - [x] Update name, notes, color, dates
  - [x] Archive/unarchive projects
  - [x] Change owner
  - [x] Modify privacy settings
- [x] Implement `project delete` command:
  - [x] Confirmation prompt (unless --force)
  - [x] Handle cascading implications
  - [x] Clear success/failure messages
- [x] Add member management:
  - [x] `project members list` - Show all members
  - [x] `project members add` - Add users by email
  - [x] `project members remove` - Remove members
  - [x] `project members update` - Change permissions
- [x] Create output formatters:
  - [x] Table formatter with column alignment
  - [x] JSON formatter with pretty print option
  - [x] CSV formatter with proper escaping
  - [x] Markdown formatter for documentation
- [x] Add filtering system:
  - [x] Parse filter expressions
  - [x] Support field comparisons
  - [x] Enable regex matching
  - [x] Allow saved filters
- [x] Implement templates:
  - [x] Define template schema in TOML
  - [x] Load from `~/.local/share/asana-cli/templates/`
  - [x] Support variable substitution
  - [x] Include default templates
- [x] Write tests:
  - [x] Unit tests for models and builders
  - [x] Integration tests for commands
  - [x] Test output formatting
  - [x] Verify template system

## Definition of Done

- All project CRUD operations work correctly
- Multiple output formats display properly
- Templates simplify project creation
- Filtering and sorting work as expected
- Member management is functional
- Tests cover happy path and edge cases
