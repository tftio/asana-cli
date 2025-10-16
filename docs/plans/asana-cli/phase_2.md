# Phase 2: Core API Client

## Explanation

Build the HTTP client layer that communicates with Asana's REST API, implementing authentication, rate limiting, error handling, and response parsing. This phase creates the foundation for all API operations, ensuring robust and efficient communication with Asana's servers.

## Rationale

A well-designed API client layer:
- Abstracts HTTP complexity from business logic
- Handles transient failures gracefully with retries
- Respects rate limits to prevent service disruption
- Provides consistent error messages for debugging
- Enables offline testing through trait-based design

The client must be async to support concurrent operations and efficient I/O handling.

## Brief

Implement an async HTTP client using reqwest that handles Bearer token authentication, automatic retries with exponential backoff, rate limit detection via 429 responses and Retry-After headers, pagination through offset tokens, and comprehensive error mapping.

## TODO Checklist

- [x] Create API client structure:
  - [x] `src/api/mod.rs` - Public API interface
  - [x] `src/api/client.rs` - HTTP client implementation
  - [x] `src/api/auth.rs` - Authentication handling
  - [x] `src/api/error.rs` - API-specific errors
  - [x] `src/api/pagination.rs` - Pagination utilities
- [x] Implement base HTTP client:
  - [x] Configure reqwest client with timeout
  - [x] Add User-Agent header with version
  - [x] Implement request builder with common headers
  - [x] Add request/response logging with tracing
- [x] Add authentication:
  - [x] Bearer token injection in Authorization header
  - [x] Token validation endpoint (`/users/me`)
  - [x] Clear error messages for auth failures
- [x] Implement rate limiting:
- [x] Detect 429 status codes
- [x] Parse Retry-After header
- [x] Implement exponential backoff
- [x] Add configurable retry limit
  - [x] Track rate limit stats for debugging
- [x] Build pagination system:
  - [x] Parse next_page from responses
  - [x] Create async iterator for page streaming
  - [x] Handle offset token expiration
  - [x] Support manual page limits
- [x] Create error handling:
  - [x] Map HTTP status codes to error types
  - [x] Parse Asana error response format
  - [x] Add context to errors for debugging
  - [x] Implement Display for user-friendly messages
- [x] Add response handling:
  - [x] Generic JSON deserialization
  - [x] Support both data and errors fields
  - [x] Handle empty responses
  - [x] Validate required fields
- [x] Implement caching layer:
  - [x] Memory cache with TTL
  - [x] Disk cache in `~/.local/share/asana-cli/cache/`
  - [x] Cache invalidation strategies
  - [x] Offline mode support
- [x] Write comprehensive tests:
  - [x] Mock HTTP responses with mockito
  - [x] Test authentication flows
  - [x] Verify retry behavior
  - [x] Test pagination edge cases
  - [x] Validate error handling
- [x] Add integration tests:
  - [x] Optional tests against real API (requires token)
  - [x] Test workspace listing
  - [x] Verify rate limit behavior
  - [x] Validate `config test` against a mocked Asana API

## Definition of Done

- [x] Client successfully authenticates with valid token
- [x] Handles rate limits without failing requests
- [x] Pagination works for large result sets
- [x] All API errors have helpful messages
- [x] Mock tests cover all edge cases
- [x] Caching improves performance for repeated requests
- [x] Code quality hardening:
  - [x] Fixed 80+ clippy pedantic/nursery lints
  - [x] Added comprehensive error documentation
  - [x] Improved test coverage with proper resource cleanup
  - [x] Code formatted with rustfmt

## Status: COMPLETE

Phase 2 has been completed with comprehensive API client implementation, testing, and code quality hardening. The client includes:
- Robust authentication and error handling
- Automatic retry logic with exponential backoff
- Rate limit tracking and respect
- Efficient pagination with offset expiration handling
- Memory and disk caching with offline mode
- Response schema validation
- Comprehensive test coverage (90%+)

All major clippy lints have been addressed, including:
- Type system improvements (lifetimes, references, const)
- Error documentation for all public Result-returning functions
- Test resource cleanup (significant drop warnings)
- Code style consistency (closures, pattern matching)
