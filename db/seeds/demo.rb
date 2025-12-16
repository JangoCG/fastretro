# frozen_string_literal: true

# Demo seeder for screenshots and demos
# Run with: bin/rails runner db/seeds/demo.rb
# Or reset and seed: bin/setup --reset && bin/rails runner db/seeds/demo.rb

puts "Creating demo data..."

# =============================================================================
# TEAM MEMBERS
# =============================================================================

TEAM_MEMBERS = [
  { name: "Sarah Chen", email: "sarah@acmecorp.com", role: "owner" },
  { name: "Marcus Johnson", email: "marcus@acmecorp.com", role: "admin" },
  { name: "Emily Rodriguez", email: "emily@acmecorp.com", role: "member" },
  { name: "David Kim", email: "david@acmecorp.com", role: "member" },
  { name: "Alex Thompson", email: "alex@acmecorp.com", role: "member" },
  { name: "Priya Patel", email: "priya@acmecorp.com", role: "member" }
].freeze

# =============================================================================
# FEEDBACK CONTENT (Realistic software team retrospective feedback)
# =============================================================================

WENT_WELL_FEEDBACKS = [
  "The new CI/CD pipeline reduced our deployment time from 45 minutes to under 10 minutes. Huge win for the team!",
  "Pair programming sessions this sprint helped catch bugs early and improved code quality significantly.",
  "Great collaboration between frontend and backend teams on the new dashboard feature.",
  "The team's response to the production incident was excellent - we had it resolved in under an hour.",
  "Daily standups have been more focused and productive since we moved them to 9:30 AM.",
  "The design system components are really paying off - building new features is much faster now.",
  "Code reviews have been thorough and constructive. Learning a lot from the feedback.",
  "Sprint planning session was well-organized and we had clear acceptance criteria for all stories.",
  "The new error monitoring tool has already helped us catch 3 issues before users reported them.",
  "Customer feedback on the new search feature has been overwhelmingly positive.",
  "Team morale has been high despite the tight deadline. Great support from everyone.",
  "Documentation for the API endpoints is comprehensive and saved onboarding time for new devs.",
  "The refactoring of the authentication module made the codebase much cleaner.",
  "QA testing caught several edge cases we hadn't considered. Good catches!",
  "The async communication in Slack has improved - fewer interruptions during focus time."
].freeze

COULD_BE_BETTER_FEEDBACKS = [
  "We underestimated the complexity of the payment integration - need better spike sessions.",
  "Test coverage dropped from 85% to 72% this sprint. We should prioritize writing tests.",
  "Too many meetings on Wednesdays - hard to find focus time for deep work.",
  "The database migrations caused 5 minutes of downtime. We need a better rollback strategy.",
  "Story points were inconsistent - some 3-pointers took longer than 8-pointers.",
  "Technical debt in the notification service is slowing down new feature development.",
  "Dependencies between teams caused blockers - we waited 3 days for the API changes.",
  "The staging environment was unstable this sprint, slowing down QA testing.",
  "We didn't have clear owners for some tasks which led to confusion.",
  "Mobile app performance on older devices needs attention - users are complaining.",
  "Sprint scope changed mid-sprint which affected our velocity and morale.",
  "The onboarding docs for the new service are incomplete - took too long to get up to speed.",
  "Error messages in the app aren't user-friendly - support tickets increased.",
  "We need better monitoring for the background job queue - it failed silently twice.",
  "Code review turnaround was slow this sprint - PRs sat for 2+ days sometimes."
].freeze

# =============================================================================
# ACTION ITEMS
# =============================================================================

ACTION_ITEMS = [
  "Set up automated test coverage reporting in CI pipeline",
  "Create runbook for database migration rollbacks",
  "Schedule technical debt grooming session for notification service",
  "Add performance monitoring for mobile app",
  "Establish PR review SLA of 24 hours",
  "Create better error message guidelines for the team",
  "Set up alerting for background job queue failures",
  "Block Wednesday afternoons as no-meeting focus time"
].freeze

# =============================================================================
# HELPER METHODS
# =============================================================================

def create_identity_and_user(account, member)
  identity = Identity.find_or_create_by!(email_address: member[:email])

  User.find_or_create_by!(account: account, identity: identity) do |user|
    user.name = member[:name]
    user.role = member[:role]
    user.verified_at = Time.current
  end
end

def create_feedback(retro:, user:, category:, content:, status: :published, group: nil)
  feedback = Feedback.create!(
    retro: retro,
    user: user,
    category: category,
    status: status,
    feedback_group: group
  )
  feedback.update!(content: content)
  feedback
end

def create_action(retro:, user:, content:, status: :drafted)
  action = Action.create!(
    retro: retro,
    user: user,
    status: status
  )
  action.update!(content: content)
  action
end

# =============================================================================
# CREATE ACCOUNT AND USERS
# =============================================================================

puts "  Creating account and users..."

account = Account.create!(name: "Acme Corp Engineering")
users = TEAM_MEMBERS.map { |member| create_identity_and_user(account, member) }

sarah = users.find { |u| u.name == "Sarah Chen" }
marcus = users.find { |u| u.name == "Marcus Johnson" }
emily = users.find { |u| u.name == "Emily Rodriguez" }
david = users.find { |u| u.name == "David Kim" }
alex = users.find { |u| u.name == "Alex Thompson" }
priya = users.find { |u| u.name == "Priya Patel" }

# =============================================================================
# RETRO 1: Active retro in voting phase (main demo retro)
# =============================================================================

puts "  Creating Sprint 47 retro (voting phase)..."

retro1 = Retro.create!(
  account: account,
  name: "Sprint 47 Retrospective",
  phase: :voting
)

# Add all participants
[sarah, marcus, emily, david, alex, priya].each_with_index do |user, index|
  role = index < 2 ? :admin : :participant
  retro1.add_participant(user, role: role)
end

# Create went_well feedbacks
went_well_content = WENT_WELL_FEEDBACKS.sample(8)
went_well_feedbacks = []

went_well_feedbacks << create_feedback(retro: retro1, user: sarah, category: :went_well, content: went_well_content[0])
went_well_feedbacks << create_feedback(retro: retro1, user: marcus, category: :went_well, content: went_well_content[1])
went_well_feedbacks << create_feedback(retro: retro1, user: emily, category: :went_well, content: went_well_content[2])
went_well_feedbacks << create_feedback(retro: retro1, user: david, category: :went_well, content: went_well_content[3])
went_well_feedbacks << create_feedback(retro: retro1, user: alex, category: :went_well, content: went_well_content[4])
went_well_feedbacks << create_feedback(retro: retro1, user: priya, category: :went_well, content: went_well_content[5])
went_well_feedbacks << create_feedback(retro: retro1, user: sarah, category: :went_well, content: went_well_content[6])
went_well_feedbacks << create_feedback(retro: retro1, user: marcus, category: :went_well, content: went_well_content[7])

# Create could_be_better feedbacks
could_be_better_content = COULD_BE_BETTER_FEEDBACKS.sample(7)
could_be_better_feedbacks = []

could_be_better_feedbacks << create_feedback(retro: retro1, user: emily, category: :could_be_better, content: could_be_better_content[0])
could_be_better_feedbacks << create_feedback(retro: retro1, user: david, category: :could_be_better, content: could_be_better_content[1])
could_be_better_feedbacks << create_feedback(retro: retro1, user: alex, category: :could_be_better, content: could_be_better_content[2])
could_be_better_feedbacks << create_feedback(retro: retro1, user: priya, category: :could_be_better, content: could_be_better_content[3])
could_be_better_feedbacks << create_feedback(retro: retro1, user: sarah, category: :could_be_better, content: could_be_better_content[4])
could_be_better_feedbacks << create_feedback(retro: retro1, user: marcus, category: :could_be_better, content: could_be_better_content[5])
could_be_better_feedbacks << create_feedback(retro: retro1, user: emily, category: :could_be_better, content: could_be_better_content[6])

# Create feedback groups (grouping related feedback)
group1 = FeedbackGroup.create!(retro: retro1, name: "CI/CD & Deployments")
went_well_feedbacks[0].update!(feedback_group: group1)
went_well_feedbacks[1].update!(feedback_group: group1)

group2 = FeedbackGroup.create!(retro: retro1, name: "Testing & Quality")
could_be_better_feedbacks[0].update!(feedback_group: group2)
could_be_better_feedbacks[1].update!(feedback_group: group2)

# Add votes (max 3 per participant)
participants = retro1.participants.to_a

# Sarah votes
Vote.create!(retro_participant: participants.find { |p| p.user == sarah }, voteable: went_well_feedbacks[1])
Vote.create!(retro_participant: participants.find { |p| p.user == sarah }, voteable: could_be_better_feedbacks[0])
Vote.create!(retro_participant: participants.find { |p| p.user == sarah }, voteable: could_be_better_feedbacks[3])

# Marcus votes
Vote.create!(retro_participant: participants.find { |p| p.user == marcus }, voteable: went_well_feedbacks[0])
Vote.create!(retro_participant: participants.find { |p| p.user == marcus }, voteable: went_well_feedbacks[2])
Vote.create!(retro_participant: participants.find { |p| p.user == marcus }, voteable: could_be_better_feedbacks[1])

# Emily votes
Vote.create!(retro_participant: participants.find { |p| p.user == emily }, voteable: could_be_better_feedbacks[0])
Vote.create!(retro_participant: participants.find { |p| p.user == emily }, voteable: could_be_better_feedbacks[4])

# David votes
Vote.create!(retro_participant: participants.find { |p| p.user == david }, voteable: went_well_feedbacks[3])
Vote.create!(retro_participant: participants.find { |p| p.user == david }, voteable: could_be_better_feedbacks[2])
Vote.create!(retro_participant: participants.find { |p| p.user == david }, voteable: could_be_better_feedbacks[5])

# Alex votes
Vote.create!(retro_participant: participants.find { |p| p.user == alex }, voteable: went_well_feedbacks[4])
Vote.create!(retro_participant: participants.find { |p| p.user == alex }, voteable: could_be_better_feedbacks[0])

# Priya votes - finished voting
priya_participant = participants.find { |p| p.user == priya }
Vote.create!(retro_participant: priya_participant, voteable: went_well_feedbacks[5])
Vote.create!(retro_participant: priya_participant, voteable: could_be_better_feedbacks[1])
Vote.create!(retro_participant: priya_participant, voteable: could_be_better_feedbacks[6])
priya_participant.finish!

# =============================================================================
# RETRO 2: Completed retro with actions (for export demo)
# =============================================================================

puts "  Creating Export Demo retro (complete)..."

retro2 = Retro.create!(
  account: account,
  name: "Export Demo",
  phase: :complete
)

[sarah, marcus, emily, david, alex, priya].each_with_index do |user, index|
  role = index < 1 ? :admin : :participant
  participant = retro2.add_participant(user, role: role)
  participant.finish!
end

# Comprehensive past sprint feedbacks for export demo
past_went_well = [
  "Successfully launched the new user onboarding flow - 40% improvement in activation rate",
  "Great teamwork during the holiday coverage - everything ran smoothly",
  "The new logging system helped debug issues much faster",
  "Reduced page load time by 35% after implementing lazy loading",
  "Zero production incidents this sprint - our best record yet!",
  "The new automated testing pipeline caught 12 bugs before they reached production",
  "Cross-team collaboration with the mobile team was seamless",
  "Sprint planning was well-organized with clear priorities"
]

past_could_be_better = [
  "Need better handoff documentation when team members are on vacation",
  "Performance testing should happen earlier in the sprint",
  "Too many context switches between projects this sprint",
  "The staging environment was down for 4 hours, blocking QA",
  "Story estimation was off - we overcommitted by 15 points",
  "Code review feedback loop took too long (avg 2 days)"
]

past_went_well.each_with_index do |content, i|
  create_feedback(retro: retro2, user: [sarah, marcus, emily, david, alex, priya][i % 6], category: :went_well, content: content)
end

past_could_be_better.each_with_index do |content, i|
  create_feedback(retro: retro2, user: [david, sarah, emily, marcus, alex, priya][i % 6], category: :could_be_better, content: content)
end

# Add comprehensive action items
completed_actions = [
  "Set up automated test coverage reporting in CI pipeline",
  "Create runbook for database migration rollbacks",
  "Schedule technical debt grooming session for notification service",
  "Add performance monitoring for mobile app",
  "Establish PR review SLA of 24 hours"
]

completed_actions.each_with_index do |content, i|
  create_action(retro: retro2, user: [sarah, marcus, emily, david, alex][i % 5], content: content, status: :published)
end

# =============================================================================
# SUMMARY
# =============================================================================

puts ""
puts "Demo data created successfully!"
puts ""
puts "Account: #{account.name} (#{account.slug})"
puts "Users: #{users.map(&:name).join(', ')}"
puts ""
puts "Retros:"
puts "  1. #{retro1.name} - #{retro1.phase} (#{retro1.feedbacks.count} feedbacks, #{retro1.participants.count} participants)"
puts "  2. #{retro2.name} - #{retro2.phase} (#{retro2.feedbacks.count} feedbacks, #{retro2.actions.published.count} actions)"
puts ""
puts "To log in as Sarah (owner): Use email sarah@acmecorp.com"
puts "To log in as Marcus (admin): Use email marcus@acmecorp.com"
puts "To log in as Emily (member): Use email emily@acmecorp.com"
