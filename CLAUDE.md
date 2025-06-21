# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Backend (Laravel)

- **Start dev environment**: `composer dev` (starts Laravel serve, queue, Reverb WebSocket, logs, and Vite concurrently)
- **Run tests**: `composer test` (runs Pest PHP tests)
- **Generate types**: `php artisan wayfinder:generate` (generates TypeScript route types)

### Frontend (Vue/TypeScript)

- **Development**: `npm run dev` (Vite dev server)
- **Build**: `npm run build` (production build)
- **SSR Build**: `npm run build:ssr` (server-side rendering build)
- **Linting**: `npm run lint` (ESLint with auto-fix)
- **Type checking**: `vue-tsc` (Vue TypeScript compiler)
- **Formatting**: `npm run format` (Prettier formatting)
- **Type generation**: `npm run typegen` (Laravel to TypeScript types)

### Database

- Migrations: `php artisan migrate`
- Fresh migrate with seeding: `php artisan migrate:fresh --seed`
- Uses SQLite for development (`database/database.sqlite`)

## Architecture Overview

### Technology Stack

- **Backend**: Laravel 12 with Inertia.js for SPA-like routing
- **Frontend**: Vue 3 Composition API with TypeScript
- **UI Framework**: ShadCN/UI components with Tailwind CSS v4
- **Real-time**: Laravel Reverb (WebSocket) with Laravel Echo
- **Testing**: Pest PHP for backend tests
- **Type Safety**: Full TypeScript integration with Laravel Wayfinder for route generation

### Core Application Structure

This is a collaborative retrospective and task management application with two main feature domains:

#### 1. Retro (Retrospective) System

- **Phase-based workflow**: WAITING → BRAINSTORMING → THEMING → VOTING → DISCUSSION → SUMMARY
- **Anonymous participation**: Users join via session-based authentication (no account required)
- **Real-time collaboration**: Live participant updates, phase transitions, and feedback grouping
- **WebSocket events**: `ParticipantJoined`, `ParticipantSelected`, `PhaseCompleted`

#### 2. Task Board System

- **Authenticated feature**: Requires user login
- **Kanban-style boards**: Columns with draggable tasks
- **Advanced task management**: Grouping, voting, ordering, hierarchical tasks
- **Self-referential relationships**: Tasks can be grouped using `group_id`

### Data Models and Relationships

#### Retro Domain

```
Retro (1) ← (many) Participant ← (many) Feedback
Retro (1) ← (many) FeedbackGroup ← (many) Feedback
```

#### Task Board Domain

```
User (1) ← (many) TaskBoard (1) ← (many) TaskColumn (1) ← (many) Task
Task (1) ← (many) Task (self-referential grouping)
```

### Frontend Architecture Patterns

#### Component Structure

- **Layout system**: Flexible layouts with `AppShell.vue` supporting header/sidebar variants
- **Page components**: Located in `resources/js/pages/` using Inertia.js routing
- **UI components**: ShadCN/UI components in `resources/js/components/ui/`
- **Feature components**: Domain-specific components (tasks, retro feedback)

#### State Management

- **Server state**: Managed through Inertia.js props
- **Local UI state**: Vue 3 reactivity system
- **Real-time updates**: Laravel Echo WebSocket integration
- **Persistent preferences**: Composables with localStorage

#### Key Composables

- `useAppearance.ts`: Theme management (light/dark/system)
- `useDragAndDrop.ts`: Drag-and-drop logic with visual feedback
- `useBoard.ts`: Task board data transformation and API interactions
- `useInitials.ts`: User avatar generation utilities

### Backend Architecture Patterns

#### Authentication Strategy

- **Dual system**: Standard Laravel auth for authenticated features + session-based auth for anonymous retro
  participation
- **Session identification**: Uses UUID `session_id` for anonymous participants
- **Helper method**: `Participant::findByCurrentSession()` for current participant lookup

#### API Patterns

- **Inertia.js integration**: Server-side rendering with Vue components
- **Resource controllers**: Standard Laravel CRUD patterns
- **Real-time broadcasting**: Events broadcast immediately via `ShouldBroadcastNow`
- **Custom endpoints**: Complex operations like task reordering, grouping, voting

#### Key API Endpoints

```
POST /retro/{retro}/join - Join retro as participant
PATCH /retro/{retro}/phase - Transition to next phase  
PUT /tasks/reorder - Reorder tasks within columns
POST /tasks/group - Group multiple tasks together
POST /tasks/group/{group}/vote - Vote on task groups
```

### Development Guidelines

#### Code Conventions (from .cursor/rules)

- Always use Vue 3 Composition API
- Use Tailwind CSS v4
- Use TypeScript throughout
- Use ShadCN/UI components (`npx shadcn-vue@latest <component-name>` to add new ones)
- If you are ussing @apply from tailwind you need to remembe to add @reference "tailwindcss" to the style section of the
  vue component or it wont work

#### Type Safety

- Laravel Wayfinder generates TypeScript route definitions
- Full TypeScript integration between frontend and backend
- Use `npm run typegen` to regenerate Laravel model types

#### Testing Strategy

- Backend: Pest PHP testing framework
- Tests located in `tests/Feature/` and `tests/Unit/`
- Authentication tests cover both standard and session-based auth

### Real-time Features

#### WebSocket Setup

- Laravel Reverb for WebSocket server
- Laravel Echo on frontend for real-time subscriptions
- Channel pattern: `retro.{retroId}` for retro-specific broadcasts
- All participants receive live updates during retro sessions

#### Drag and Drop Implementation

- Multi-layered approach with visual feedback
- Supports task reordering, grouping, and feedback organization
- `useDragAndDrop.ts` composable provides reusable logic
- Integration with backend APIs for persistence

### Development Workflow

1. **Start development**: Run `composer dev` to start all services concurrently
2. **Database changes**: Create migrations, run `php artisan migrate`
3. **Frontend changes**: Auto-reloading via Vite dev server
4. **Type updates**: Run `npm run typegen` after backend model changes
5. **Route changes**: Run `npm run wayfinder:generate` after route modifications
6. **Testing**: Use `composer test` for PHP tests

### File Organization

#### Backend

- `app/Models/`: Eloquent models with relationships
- `app/Http/Controllers/`: Feature-organized controllers
- `app/Events/`: Real-time broadcasting events
- `database/migrations/`: Database schema evolution
- `routes/`: Route definitions by feature

#### Frontend

- `resources/js/pages/`: Inertia.js pages by feature
- `resources/js/components/`: Reusable Vue components
- `resources/js/composables/`: Shared reactive logic
- `resources/js/types/`: TypeScript type definitions
- `resources/js/routes/`: Frontend route helpers

This architecture supports both individual task management and collaborative retrospective sessions through a unified
design system and shared technical patterns.

### Development Notes

- We are still in development, if you need to change the database tables always just edit the original migrations and run `php artisan migrate:fresh`