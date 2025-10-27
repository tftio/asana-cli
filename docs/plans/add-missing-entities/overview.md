# Add Missing Asana API Entities - Implementation Plan

## Executive Summary

This plan documents the phased implementation of missing Asana API functionality in the asana-cli tool. The implementation is prioritized for individual contributor use cases, focusing on daily-use features like task comments, search, and workspace discovery.

**Current Status**: Tag management recently added (Phase 0)
**Target**: 8 additional phases covering Stories, Workspaces/Users, Search, Attachments, Status Updates, Teams, and Premium/Enterprise features

## Goals

1. **Complete Daily-Use Features**: Comments, search, workspace discovery
2. **File Management**: Attachment upload/download
3. **Project Reporting**: Status updates
4. **Organization Discovery**: Teams, users
5. **Premium Support**: Graceful handling with clear upgrade messaging

## Scope

### In Scope
- Task comments (user-created stories)
- Workspace and user discovery
- Workspace-scoped task search
- Attachment file management
- Project status updates
- Team discovery
- Premium/Enterprise features (marked clearly)

### Out of Scope
- Custom field management (deferred - user doesn't find it useful currently)
- System-generated activity stories (only user comments)
- Cross-workspace search (workspace-scoped only)
- Attachment cloud storage integration (local files only)

## Architecture Decisions

### Pattern Consistency
Follow established patterns from existing implementations:
- **Models**: `src/models/{resource}.rs` with builder patterns
- **API**: `src/api/{resource}.rs` with async functions
- **CLI**: `src/cli/{resource}.rs` or extend existing task/project CLIs
- **Exports**: Update `src/models/mod.rs` and `src/api/mod.rs`

### Builder Pattern
All create/update operations use builder pattern:
```rust
StoryCreateBuilder::new(task_gid, "comment text")
    .is_pinned(true)
    .build()?
```

### Error Handling
Extend existing `ApiError` enum for new error cases:
- Premium feature access (402 Payment Required)
- Enterprise feature access (403 Forbidden with specific message)
- File upload errors (413 Payload Too Large, unsupported types)

### Output Formats
All list/show commands support:
- `--format table` (default, TTY-aware)
- `--format json` (machine-readable)
- `--format detail` (human-readable expanded view)

### Premium/Enterprise Feature Handling

**Help Text Marking**:
```
  portfolio list          List portfolios [Premium]
  audit-log events        Get audit log events [Enterprise]
```

**Error Messages**:
```rust
if response.status() == 402 {
    return Err(ApiError::PremiumRequired(
        "Portfolios require Asana Premium. Upgrade at https://asana.com/pricing"
    ));
}
```

## Phase Overview

| Phase | Feature | Priority | Status | Dependencies |
|-------|---------|----------|--------|--------------|
| 0 | Tags | Complete | ✅ Done | - |
| 1 | Stories (Comments) | Highest | 📋 Planned | - |
| 2 | Workspaces & Users | High | 📋 Planned | - |
| 3 | Search | High | 📋 Planned | Phase 2 |
| 4 | Attachments | Medium | 📋 Planned | - |
| 5 | Status Updates | Medium | 📋 Planned | - |
| 6 | Teams | Lower | 📋 Planned | Phase 2 |
| 7 | Premium Features | Lower | 📋 Planned | Phase 2 |
| 8 | Enterprise Features | Lowest | 📋 Planned | Phase 2 |

## Phase Status Legend
- 📋 **Planned** - Design phase, not started
- 🚧 **In Progress** - Active development
- ✅ **Done** - Implemented, tested, documented
- ⏸️ **Blocked** - Waiting on dependency or decision
- ❌ **Deferred** - Pushed to future release

## Implementation Principles

1. **User-Centric**: Prioritize features used daily by individual contributors
2. **Consistent UX**: Follow patterns from tasks/projects/sections/tags
3. **Quality First**: 80% test coverage, clippy pedantic compliance
4. **Graceful Degradation**: Never fail silently on premium features
5. **Documentation**: Update help text, examples, README
6. **Incremental**: Each phase is independently useful

## Technical Constraints

- **Rust Edition**: 2021
- **Linting**: Clippy pedantic mode must pass
- **Testing**: 80% line coverage minimum
- **Async Runtime**: Tokio with current_thread runtime
- **HTTP Client**: Reqwest with connection pooling
- **Output**: TTY-aware (colored when interactive, plain when piped)
- **Error Handling**: Comprehensive Result types, context on errors

## Success Criteria

### Phase Completion Criteria
Each phase is considered complete when:
1. ✅ All planned models implemented with builders
2. ✅ All API operations functional and tested
3. ✅ CLI commands implemented with help text
4. ✅ Unit tests at 80%+ coverage
5. ✅ Integration tests for happy paths
6. ✅ Clippy pedantic passes
7. ✅ Documentation updated (README, examples)
8. ✅ Manual testing checklist completed

### Overall Project Success
The project is successful when:
1. ✅ Phases 1-3 complete (Stories, Workspaces/Users, Search)
2. ✅ Phase 4 complete (Attachments)
3. ✅ Premium features gracefully handle access restrictions
4. ✅ All tests passing in CI
5. ✅ User documentation comprehensive
6. ✅ Performance acceptable (no obvious bottlenecks)

## Risk Assessment

### High Risk
- **Multipart Upload Complexity**: Attachment uploads require multipart/form-data
  - *Mitigation*: Use reqwest multipart forms, well-tested in ecosystem

- **Search Performance**: Large workspaces may have slow searches
  - *Mitigation*: Implement client-side pagination, allow limit parameter

### Medium Risk
- **Premium Feature Testing**: Hard to test without Premium subscription
  - *Mitigation*: Mock 402 responses, document expected behavior

- **Breaking API Changes**: Asana may update API without notice
  - *Mitigation*: Pin API version in requests, monitor changelog

### Low Risk
- **CLI UX Consistency**: New commands may diverge from patterns
  - *Mitigation*: Code review checklist, follow established templates

## Dependencies

### External Crates (already in use)
- `tokio` - Async runtime
- `reqwest` - HTTP client
- `serde` / `serde_json` - Serialization
- `clap` - CLI argument parsing
- `anyhow` - Error handling
- `colored` - Terminal colors

### May Need to Add
- `mime_guess` - For attachment type detection (Phase 4)
- `indicatif` - Progress bars for file uploads (Phase 4)

## Phase Documents

Detailed phase plans:
- [Phase 1: Stories (Comments)](./phase_1_stories.md)
- [Phase 2: Workspaces & Users](./phase_2_workspaces_users.md)
- [Phase 3: Search](./phase_3_search.md)
- [Phase 4: Attachments](./phase_4_attachments.md)
- [Phase 5: Status Updates](./phase_5_status_updates.md)
- [Phase 6: Teams](./phase_6_teams.md)
- [Phase 7: Premium Features](./phase_7_premium_features.md)
- [Phase 8: Enterprise Features](./phase_8_enterprise_features.md)

## Timeline Estimate

Assuming one developer working part-time:

| Phase | Estimated Effort | Rationale |
|-------|------------------|-----------|
| 1 | 4-6 hours | Comments straightforward, extends task CLI |
| 2 | 6-8 hours | Two new resources, new CLI modules |
| 3 | 3-4 hours | Extends existing task API/CLI |
| 4 | 8-10 hours | Multipart upload complexity |
| 5 | 4-5 hours | Similar to stories, simpler model |
| 6 | 4-5 hours | Similar to workspaces/users |
| 7 | 3-4 hours | Mainly error handling |
| 8 | 2-3 hours | Documentation and graceful errors |
| **Total** | **34-45 hours** | ~1 week full-time or 2-3 weeks part-time |

## Next Steps

1. Review and approve this overview
2. Read detailed phase documents
3. Prioritize phases (recommend 1→2→3 sequence)
4. Begin Phase 1 implementation
5. Iterate based on feedback

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2025-10-26 | Initial plan created | Claude |
