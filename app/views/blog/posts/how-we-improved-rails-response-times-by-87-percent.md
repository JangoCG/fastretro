---
title: How We Improved Rails Response Times by 87%
date: 2026-02-08
author: Cengiz
description: We added Prometheus monitoring to Fast Retro and immediately spotted controllers with 200-400ms p95 latency. Here's how we traced them to N+1 queries and cut response times by up to 90%.
---

I recently added Prometheus monitoring to Fast Retro. Within hours of deploying it, I was staring at Grafana dashboards that told me exactly where my app was slow. Three controllers stood out with p95 response times between 240ms and 400ms. All of them turned out to be N+1 query problems hiding in plain sight.

## Setting Up the Metrics Pipeline

Fast Retro runs on Rails 8.1 with [Yabeda](https://github.com/yabeda-rb/yabeda) as the metrics framework and Prometheus as the backend. The setup is straightforward:

```ruby
# Gemfile
gem "yabeda"
gem "yabeda-rails"
gem "yabeda-prometheus-mmap"
gem "yabeda-actioncable"
gem "yabeda-activejob"
```

The `yabeda-rails` gem automatically tracks controller response times, request counts, and status codes. Once Prometheus scrapes those metrics, you can build Grafana dashboards that show p50, p95, and p99 latency per controller action.

That's exactly what I did. And the numbers were not great.

## The Three Slow Controllers

My Grafana dashboard showed three controllers with concerning p95 latency:

| Controller | Action | p95 Latency |
|---|---|---|
| `Retros::DiscussionsController` | show | **400ms** |
| `RetrosController` | index | **360ms** |
| `Retros::VotingsController` | show | **243ms** |

For a retrospective tool where real-time responsiveness matters, these numbers were too high. Time to dig in.

## Bug #1: Discussion Phase — 400ms

The discussion phase renders two columns of feedback cards, each showing vote counts from the previous voting phase. I opened the controller and found... nothing suspicious. It's a one-liner:

```ruby
def show
end
```

All the work happens in `Retros::ColumnComponent`, which loads feedbacks and renders them as cards. The feedbacks query looked reasonable at first glance:

```ruby
def feedbacks
  @retro.feedbacks.published.in_category(@category)
end
```

But the template renders each feedback with its author name, rich text content, vote count, and feedback group — none of which were eager-loaded. For a retro with 20 feedbacks, that's:

- 20 queries for `feedback.user` (author name)
- 20 queries for `feedback.rich_text_content` (ActionText)
- 20 queries for `feedback.votes.count` (vote badge)
- 20 queries for `feedback.feedback_group` (group membership)

**80+ queries** for a single page load.

**The fix:** One `includes` call:

```ruby
def feedbacks
  base = @retro.feedbacks.published.in_category(@category)
    .includes(:user, :rich_text_content)
  base = base.includes(:votes, feedback_group: :votes) if show_vote_results?
  base
end
```

And changing `.count` to `.size` everywhere, so Rails uses the preloaded collection instead of firing a new `COUNT(*)`:

```ruby
# Before: fires a SQL COUNT(*) query
feedback.votes.count

# After: uses the already-loaded array
feedback.votes.size
```

This is a subtle but important distinction in Rails. `.count` always hits the database. `.size` checks if the association is already loaded and uses `.length` on the array if it is.

## Bug #2: Retros Index — 360ms

The retros index page shows a grid of cards, one per retro. Each card displays a "ITEMS" count of published feedbacks. Here's the component:

```ruby
class Retros::RetroCardComponent < ApplicationComponent
  def feedback_count
    @retro.feedbacks.published.count
  end
end
```

Simple, right? But with 30 retros on the page, that's 30 separate `COUNT(*)` queries. Classic N+1.

**The fix:** Batch-load all counts in a single `GROUP BY` query in the controller and pass them to the component:

```ruby
# Controller
def index
  @retros = Current.account.retros
  @feedback_counts = Feedback.where(retro: @retros)
    .published.group(:retro_id).count
end
```

```erb
<%# View %>
<%= render Retros::RetroCardComponent.new(
  retro: retro,
  feedback_count: @feedback_counts[retro.id] || 0
) %>
```

One query instead of N. Done.

## Bug #3: Voting Phase — 243ms

This was the most interesting one. The voting phase renders a `VoteButtonComponent` for every feedback and feedback group on the board. Each button shows the total vote count, the current user's votes, and a +/- button based on whether the user has votes remaining.

Here's what the component was doing per button:

```ruby
def total_votes
  @voteable.votes.count          # COUNT(*) query
end

def user_votes
  @participant.votes.where(voteable: @voteable)  # SELECT query
end

def user_vote_count
  user_votes.count               # another COUNT(*) query
end

def can_add_vote?
  @participant.votes.count < 3   # the SAME COUNT(*) for every button!
end
```

For a board with 10 voteable items, that's **~50 queries**. The `can_add_vote?` method was the worst offender — it fires the exact same query (`SELECT COUNT(*) FROM votes WHERE retro_participant_id = ?`) for every single button on the page, even though the answer is the same for all of them.

**The fix:** Eager-load the participant's votes and filter in Ruby:

```ruby
def total_votes
  @voteable.votes.size
end

def user_votes
  @participant.votes.select { |v|
    v.voteable_type == @voteable.class.name &&
    v.voteable_id == @voteable.id
  }
end

def can_add_vote?
  @participant.votes.size < 3
end
```

The participant's votes are preloaded once (with `includes(:votes)` on the participant query), and everything else is just array filtering. From ~50 queries down to 3.

## The Pattern

All three bugs followed the same pattern:

1. **A component does something reasonable in isolation** — calling `.count` or accessing an association.
2. **The component gets rendered in a loop** — once per feedback, once per retro card, once per vote button.
3. **Each render fires its own query** — turning O(1) into O(N).

The fixes also followed a pattern:

- **Eager-load associations** with `includes` at the query level
- **Use `.size` instead of `.count`** to leverage preloaded data
- **Batch-load aggregate data** (counts, sums) with `GROUP BY` when you only need numbers
- **Filter preloaded collections in Ruby** instead of hitting the DB per iteration

## What Prometheus Gave Us

Without metrics, these issues would have been invisible. The app "worked fine" — pages loaded, votes were cast, discussions happened. The N+1 queries added maybe 200-300ms of latency, spread across dozens of tiny queries that individually looked fast.

Prometheus made the slow controllers impossible to ignore. A p95 of 400ms on a Grafana dashboard is a clear signal that something is wrong. From there, it was just a matter of reading the code and asking "where are the loops?"

If you're running a Rails app without request-level metrics, you're flying blind. Yabeda + Prometheus + Grafana took about an hour to set up and immediately paid for itself.
