# Changelog

All notable changes to this project will be documented in this file.

## [0.0.4.0] - 2026-04-16

### Added
- Background jobs now automatically carry the enqueue-time account context through to perform. Previously, async work could run without tenant scope; any future notifications, digests, or broadcasts will stay inside the account that triggered them.
- Mailer deliveries and Turbo Streams broadcast jobs carry the same account context, so emails render with the correct tenant URLs and async page updates stay scoped to the right workspace.
- Regression test coverage for the Jira export background job (the suite had no job-level tests before).

### Changed
- Jobs whose referenced account has been deleted before the job runs are now cleanly discarded instead of retrying.

## [0.0.3.1] - 2026-04-15

### Added
- Block search engine indexing on all app pages via X-Robots-Tag header (deny-by-default)
- `allow_search_engine_indexing` opt-out for public SEO pages (landing, blog, alternatives, shoutouts, sitemap)
- Tests for BlockSearchEngineIndexing concern

### Fixed
- Brakeman XSS warnings: replaced `.html_safe` with `_html` i18n key suffix for auto-escaped interpolations
- System test flakiness: disabled Turbo auto-connect after visit (tests wait for cable explicitly where needed)
- Removed unreliable multi-session Action Cable system test (not supported in headless Chrome)

## [0.0.3.0] - 2026-04-15

### Added
- Passkey (WebAuthn) authentication as an alternative to magic links
- Pure-Ruby WebAuthn implementation (CBOR decoder, COSE key parser, attestation/assertion validation)
- Passkey registration and management UI at /my/passkeys
- "Sign in with a passkey" button on login page with conditional mediation (autofill)
- Passkey challenge endpoint for just-in-time challenge generation (no server-side session state)
- Web components for passkey registration and sign-in ceremonies
- Controller tests for passkey authentication and management flows

## [0.0.2.0] - 2026-04-15

### Changed
- Magic link authentication now uses signed, expiring cookies instead of Rails session storage for pending email verification (aligned with Fizzy's hardened auth)
- Action Cable connections now identify by User+Account instead of Identity alone, improving multi-tenant WebSocket isolation
- Sessions controller restructured with separate sign_in/sign_up flows and rate limit handler methods

### Added
- Fake magic link flow for unknown email addresses prevents email enumeration attacks
- `Authentication::ViaMagicLink` concern extracts magic link logic into its own module
- `session_token` helper method on Authentication concern
- New tests: fake magic link flow, email mismatch rejection, cookie-based assertions, resend with cookie

### Security
- Pending authentication tokens are now cryptographically signed with `MessageVerifier` and expire with the magic link
- Unknown emails get the same visual flow as known emails (no timing side-channel)
- Leak protection for magic link codes now checks `Rails.env.development?` directly

## [0.0.1.0] - 2026-04-15

### Changed
- Free tier limit now counts retros instead of feedbacks (5 free retros, previously 10 feedbacks)
- Users see the limit upfront when creating a retro, not mid-session when publishing feedback
- Limit is enforced on the "New Retro" form and create action, with role-aware messaging
- Admin stats leaderboard now ranks accounts by retro count

### Removed
- `feedbacks_count` column from accounts (replaced by `retros_count`)
- `lifetime_feedbacks_count` column from identities (unused)
- Unused feedback limit controller concerns

## [0.0.0.2] - 2026-04-14

### Fixed
- The "complete phase" confirmation modal now updates in real-time when participants mark themselves as finished, so admins always see the correct status instead of a stale "not everyone is finished" warning

## [0.0.0.1] - 2026-04-14

### Fixed
- Account settings page is now centered, matching fizzy's layout approach with flex-based centering instead of a CSS grid that left content aligned to the left when fewer panels were visible
