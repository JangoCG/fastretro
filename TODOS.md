# TODOS

## Retros

### Protect in-progress drafts from role-change page refreshes

**What:** Mark draft form fields (feedback textarea, action composer) with `data-turbo-permanent`, or replace the role-change full-page refresh with targeted stream updates of the admin-dependent regions.

**Why:** When a participant's role changes, `Retro::Participant#broadcast_role_change_refresh` triggers a Turbo morph refresh of their page. If they are mid-typing a feedback draft or action item at that moment, the morph can re-render the form from server state and discard unsaved input.

**Context:** Found by /ship red-team review on the participant-role-management branch. Role changes are rare events, so the risk window is small, but the fix is the exact scenario `data-turbo-permanent` exists for. See `app/models/retro/participant.rb` (`broadcast_role_change_refresh`) and `app/views/layouts/retro.html.erb` (`turbo_refreshes_with method: :morph`).

**Effort:** S
**Priority:** P3
**Depends on:** None

### Focus-visible styles for participant role buttons

**What:** Add an explicit focus state to `ParticipantRoleButtonComponent`, e.g. `focus-visible:bg-[#ffe600] focus-visible:outline-2 focus-visible:outline-zinc-900 focus-visible:outline-offset-2`.

**Why:** Keyboard users currently get the UA default focus ring, which clashes with the hard-border neo-brutalist styling; every other interactive treatment in these views styles its states explicitly.

**Context:** Design specialist finding from /ship review. The shared button component lives at `app/components/participant_role_button_component.rb`.

**Effort:** S
**Priority:** P3
**Depends on:** None

### Skip redundant participant-list broadcast for the user receiving a role-change refresh

**What:** When a role change fires both `broadcast_targeted_participant_updates` and `broadcast_role_change_refresh`, skip the targeted replace for the affected user (they reload the full page anyway).

**Why:** The targeted replace rendered for the promoted/demoted user is discarded work — the refresh immediately re-renders their whole page.

**Context:** Performance specialist finding from /ship review; micro-optimization, kept out of the feature PR to avoid extra branching in the broadcast path. See `app/models/retro/participant.rb`.

**Effort:** S
**Priority:** P4
**Depends on:** None

## Completed
