# GitHub Copilot Instructions for FastRetro

## Project Overview

FastRetro is a real-time collaborative retrospective and task management application built with Laravel 12 and Vue 3. It supports anonymous retrospective participation with phase-based workflows and authenticated task board management with Kanban-style organization.

## Technology Stack

### Backend
- **Laravel 12** with Inertia.js for SPA-like routing
- **Laravel Reverb** for WebSocket real-time collaboration
- **SQLite** for development database
- **Pest PHP** for testing

### Frontend
- **Vue 3** with Composition API (always use Composition API, never Options API)
- **TypeScript** for type safety
- **Tailwind CSS v4** for styling
- **ShadCN/UI** for component library (via `reka-ui`)
- **Vite** for build tooling

## Code Style and Conventions

### General Rules
- Use TypeScript throughout the frontend
- Use Vue 3 Composition API exclusively
- Use Tailwind CSS v4 utility classes
- Use ShadCN/UI components for UI elements
- When using `@apply` in Vue components, add `@reference "tailwindcss"` to the style section
- Follow Laravel PSR-12 coding standards for PHP
- Use Pest PHP for all tests

### Vue Component Structure
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import type { PropType } from 'vue'

// Props definition
defineProps<{
  title: string
  items?: Array<Item>
}>()

// Emits definition
const emit = defineEmits<{
  update: [value: string]
  delete: [id: string]
}>()

// Composables
const { isDark } = useAppearance()

// Component logic
</script>

<template>
  <!-- Template content -->
</template>

<style scoped>
/* Tailwind utilities only, or with @reference directive */
</style>
```

### TypeScript Patterns
- Use explicit type annotations for props and emits
- Leverage type inference where possible
- Use `PropType` for complex prop types
- Generate Laravel types using `npm run typegen`

### PHP/Laravel Patterns
- Use typed properties in models and classes
- Use explicit return types on methods
- Follow repository pattern for complex queries
- Use Laravel's built-in features (Events, Broadcasting, Jobs, etc.)

## Architecture Patterns

### Dual Authentication System
1. **Standard Auth**: For authenticated task board features
2. **Session-Based Auth**: For anonymous retro participation using UUID `session_id`

When working with retro features:
- Use `Participant::findByCurrentSession()` to get current participant
- Store `session_id` in session for anonymous users
- Don't require user authentication for retro participation

### Real-Time Features
- Use Laravel Reverb for WebSocket connections
- Broadcast events with `ShouldBroadcastNow` interface
- Use Laravel Echo on frontend for listening to events
- Key events: `ParticipantJoined`, `PhaseCompleted`, `ActionCreated`, `GroupCreated`

### Data Models

#### Retro Domain
```
Retro (phases: WAITING → BRAINSTORMING → THEMING → VOTING → DISCUSSION → SUMMARY)
├── Participants (session-based, anonymous)
├── Feedback (what went well / could be better)
└── FeedbackGroups (grouped feedback for voting)
```

#### Task Board Domain
```
User
└── TaskBoard (authenticated feature)
    └── TaskColumn
        └── Task (self-referential for grouping, has votes and order)
```

### Frontend Component Organization
```
resources/js/
├── pages/              # Inertia.js pages
│   ├── retro/         # Retro feature pages
│   ├── auth/          # Authentication pages
│   └── settings/      # Settings pages
├── layouts/           # Layout components
│   ├── app/          # App layouts
│   ├── auth/         # Auth layouts
│   └── retro/        # Retro layouts
├── components/        # Reusable components
│   └── ui/           # ShadCN/UI components
└── composables/       # Vue composables
    ├── useAppearance.ts
    ├── useDragAndDrop.ts
    └── useBoard.ts
```

## Development Commands

### Starting Development
```bash
composer dev  # Starts Laravel, queue, Reverb, logs, and Vite
```

### Backend Commands
```bash
composer test                    # Run Pest tests
php artisan migrate              # Run migrations
php artisan migrate:fresh --seed # Fresh DB with seed data
php artisan wayfinder:generate   # Generate TypeScript routes
```

### Frontend Commands
```bash
npm run dev          # Start Vite dev server
npm run build        # Production build
npm run build:ssr    # SSR build
npm run lint         # ESLint with auto-fix
npm run format       # Format with Prettier
npm run typegen      # Generate Laravel types
vue-tsc              # TypeScript type checking
```

### Adding Components
```bash
npx shadcn-vue@latest <component-name>
```

## API Patterns

### Inertia.js Controllers
```php
use Inertia\Inertia;

return Inertia::render('PageName', [
    'data' => $data,
]);
```

### Broadcasting Events
```php
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;

class EventName implements ShouldBroadcastNow
{
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('retro.'.$this->retro->id),
        ];
    }
}
```

### Frontend Real-Time Listeners
```typescript
import { router } from '@inertiajs/vue3'

Echo.private(`retro.${retroId}`)
  .listen('EventName', (event: EventType) => {
    // Handle event
    router.reload({ only: ['participants'] })
  })
```

## Key Features

### Retro Phase Management
- Retros follow a strict phase progression
- Use `Retro::transitionToNextState()` to advance phases
- Broadcast `PhaseCompleted` event for real-time updates
- Different UI components per phase (Waiting, Brainstorming, Theming, Voting, Discussion, Summary)

### Task Board Features
- Drag-and-drop reordering within columns
- Task grouping with self-referential relationships
- Voting system on tasks and groups
- Hierarchical task display

### Drag and Drop
- Use `useDragAndDrop.ts` composable
- Integrates with SortableJS
- Provides visual feedback during drag operations
- Handles both task and feedback dragging

## Testing Guidelines

### Pest PHP Tests
```php
test('description', function () {
    // Arrange
    $retro = Retro::factory()->create();
    
    // Act
    $response = $this->post(route('retro.join', $retro));
    
    // Assert
    $response->assertRedirect();
    expect(Participant::count())->toBe(1);
});
```

### Test Structure
- Feature tests in `tests/Feature/`
- Unit tests in `tests/Unit/`
- Use factories for model creation
- Test both authenticated and session-based flows

## Common Tasks

### Adding a New Retro Phase Component
1. Create component in `resources/js/pages/retro/components/`
2. Add phase constant to `Retro.php` model
3. Update `$stateFlow` array in `Retro.php`
4. Import and conditionally render in `ShowRetro.vue`
5. Add broadcast event for phase transition

### Adding a New Task Board Feature
1. Add controller method in `app/Http/Controllers/`
2. Define route in `routes/web.php` with auth middleware
3. Create/update Vue components in `resources/js/pages/`
4. Add TypeScript types with `npm run typegen`
5. Update `useBoard.ts` composable if needed

### Adding a ShadCN Component
```bash
npx shadcn-vue@latest <component-name>
```
Component will be added to `resources/js/components/ui/`

## Performance Considerations

- Use Inertia.js partial reloads: `router.reload({ only: ['key'] })`
- Debounce WebSocket events to prevent excessive re-renders
- Use `v-memo` for expensive list items
- Lazy load heavy components with `defineAsyncComponent`
- Optimize database queries with eager loading

## Type Safety

- Run `npm run typegen` after modifying Laravel models
- Run `vue-tsc` to check TypeScript errors
- Use Laravel Wayfinder for type-safe routing: `php artisan wayfinder:generate`
- Import generated types from `@/types/generated.d.ts`

## Error Handling

- Use try-catch blocks for async operations
- Display user-friendly error messages
- Log errors for debugging
- Use Laravel's exception handler for backend errors
- Use Vue's error boundary for frontend errors

## Accessibility

- Use semantic HTML
- Include ARIA labels where needed
- Ensure keyboard navigation works
- Maintain sufficient color contrast
- Test with screen readers

## Security

- Use CSRF protection (included with Inertia.js)
- Validate all inputs server-side
- Use authorization policies for user actions
- Sanitize user-generated content
- Keep dependencies updated

## Notes for Copilot

- When suggesting code, prefer complete implementations over placeholders
- Use existing patterns and composables from the codebase
- Follow the dual authentication system (user auth vs session auth)
- Remember that retros are anonymous and tasks require authentication
- Always use Composition API for Vue components
- Include TypeScript types in all suggestions
- Use ShadCN/UI components instead of creating custom UI from scratch
- Consider real-time implications when modifying data
