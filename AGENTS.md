# Fast Retro

This file provides guidance to AI coding agents working with this repository.

## What is Fast Retro?

Fast Retro is a retrospective management tool for agile teams built with Ruby on Rails 8.1. It helps teams run structured retrospective sessions with real-time collaboration, featuring phases for brainstorming, grouping, voting, and discussion.

## Development Commands

### Setup and Server
```bash
bin/setup              # Initial setup (installs gems, creates DB, loads schema)
bin/dev                # Start development server (runs on port 3000)
```

Development URL: http://localhost:3000
Login with: david@example.com (development fixtures)

### Testing
```bash
bin/rails test                    # Run unit tests (fast)
bin/rails test test/path/file_test.rb  # Run single test file
bin/rails test:system             # Run system tests (Capybara + Selenium)
bin/ci                            # Run full CI suite (style, security, tests)

# For parallel test execution issues, use:
PARALLEL_WORKERS=1 bin/rails test
```

CI pipeline (`bin/ci`) runs:
1. Rubocop (style)
2. Bundler audit (gem security)
3. Importmap audit
4. Brakeman (security scan)
5. Gitleaks (secret detection)
6. Application tests (SaaS + OSS modes)
7. System tests
8. Seed tests

### Database
```bash
bin/rails db:fixtures:load   # Load fixture data
bin/rails db:migrate          # Run migrations
bin/rails db:reset            # Drop, create, and load schema
```

### Other Utilities
```bash
bin/jobs                     # Manage Solid Queue jobs
bin/kamal deploy             # Deploy (requires secrets setup)
```

## Architecture Overview

### Multi-Tenancy (URL-Based)

Fast Retro uses **URL path-based multi-tenancy**:
- Each Account (tenant) has a unique `external_account_id`
- URLs are prefixed: `/{account_id}/retros/...`
- All models include `account_id` for data isolation
- Background jobs automatically serialize and restore account context

**Key insight**: This architecture allows multi-tenancy without subdomains or separate databases, making local development and testing simpler.

### Authentication & Authorization

**Passwordless magic link authentication**:
- Global `Identity` (email-based) can have `Users` in multiple Accounts
- Users belong to an Account and have roles: owner, admin, member
- Sessions managed via signed cookies
- `Current` thread-local attributes (session, identity, user, account) set per-request

### Core Domain Models

**Account** → The tenant/organization
- Has users, retros
- Has join codes for inviting users

**Identity** → Global user (email)
- Can have Users in multiple Accounts
- Session management tied to Identity

**User** → Account membership
- Belongs to Account and Identity
- Has role (owner/admin/member)

**Retro** → A retrospective session
- Has phases: waiting_room → brainstorming → grouping → voting → discussion → complete
- Has participants with roles (admin/participant)
- Real-time updates via Turbo Streams

**Feedback** → Items created during brainstorming
- Categories: went_well, could_be_better
- Can be grouped into FeedbackGroups
- Can receive votes

**FeedbackGroup** → Groups related feedbacks
- Created during grouping phase
- Aggregates votes from contained feedbacks

**Action** → Action items from discussions
- Created during discussion phase
- Tracks follow-up tasks

**Vote** → Voting on feedbacks/groups
- Used during voting phase
- Configurable vote limit per participant

### Background Jobs (Solid Queue)

Database-backed job queue (no Redis):
- Jobs automatically capture/restore `Current.account`
- Mission Control::Jobs for monitoring

### SaaS Mode

Toggle SaaS features via:
- `SAAS=true` environment variable
- `tmp/saas.txt` file

SaaS mode enables:
- Usage limits and paywall
- Subscription management
- Stripe integration (webhooks at `/stripe/webhooks`)

## Tools

### Chrome MCP (Local Dev)

URL: `http://localhost:3000`
Login: david@example.com (passwordless magic link auth)

Use Chrome MCP tools to interact with the running dev app for UI testing and debugging.

## Pre-commit checklist

Always run the local CI suite before committing:

```bash
bin/ci
```

This catches style violations, security issues, and test failures before they reach the remote pipeline.

## Coding style

@STYLE.md
