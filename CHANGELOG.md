# Changelog

All notable changes to this project will be documented in this file.

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
