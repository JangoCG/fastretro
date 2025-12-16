# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Fast Retro is a Ruby on Rails 8.1 retrospective management tool for agile teams. It uses SQLite, Hotwire (Turbo + Stimulus), Tailwind CSS, and ViewComponent for the UI.

## Common Commands

```sh
bin/setup              # Initial setup (install deps, create DB, seed)
bin/setup --reset      # Reset database and seed
bin/dev                # Start development server (http://localhost:3000)
bin/rails test         # Run unit tests
bin/rails test:system  # Run system tests
bin/rails test TEST=test/models/retro_test.rb  # Run a single test file
bin/ci                 # Full CI suite (rubocop, security audits, all tests, seed tests)
bin/rubocop -A         # Lint and auto-fix Ruby code
```

## Architecture

### Multi-Tenant Structure

The app uses a multi-tenant architecture with account-scoped URLs:
- `Identity`: Global user identity (email, auth sessions). One identity can belong to multiple accounts.
- `Account`: Tenant container. Has join codes for inviting users.
- `User`: Identity's membership in an account (has role: owner/admin/member).
- `Current`: Thread-local attributes (session, identity, user, account) set per-request.

Authentication uses magic links (passwordless) via the `MagicLink` model and `Authentication` concern.

### Core Domain Models

- `Retro`: A retrospective session with phases (waiting_room → brainstorming → grouping → voting → discussion → complete)
- `Retro::Participant`: Join table linking users to retros with roles (admin/participant)
- `Feedback`: Items created during brainstorming (went_well/could_be_better categories)
- `FeedbackGroup`: Groups feedbacks during the grouping phase
- `Action`: Action items created from feedback discussions
- `Vote`: Voting on feedbacks/groups during the voting phase

### Real-Time Updates

Uses Turbo Streams with `broadcasts_refreshes_to` for live updates during retros.

### ViewComponents

Reusable UI components in `app/components/` (ButtonComponent, PhaseTagComponent, VoteButtonComponent, etc.).

### Stripe Integration

SaaS billing with Stripe subscriptions. Webhooks at `/stripe/webhooks`. Free tier has a feedback limit (`FREE_FEEDBACK_LIMIT` env var).

### Key Concerns

- `Authentication`: Magic link auth, session management, account scoping
- `Authorization`: Role-based access control (owner/admin/member)
- `RetroAuthorization`: Retro-specific access control (participant/admin checks)
