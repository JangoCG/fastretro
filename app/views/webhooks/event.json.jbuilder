json.event do
  json.id @event.id
  json.action @event.action.to_s
  json.created_at @event.created_at.utc.iso8601
  json.particulars @event.particulars
end

json.retro do
  json.id @event.retro.id
  json.name @event.retro.name
  json.phase @event.retro.phase
end

json.account do
  json.id @event.account.id
  json.name @event.account.name
end

if @event.creator
  json.creator do
    json.id @event.creator.id
    json.name @event.creator.name
  end
end

json.eventable do
  case @event.eventable
  when Retro
    json.type "retro"
    json.id @event.eventable.id
    json.name @event.eventable.name
    json.phase @event.eventable.phase
  when Feedback
    json.type "feedback"
    json.id @event.eventable.id
    json.category @event.eventable.category
    json.status @event.eventable.status
    json.content @event.eventable.content.to_plain_text
  when Action
    json.type "action"
    json.id @event.eventable.id
    json.status @event.eventable.status
    json.completed @event.eventable.completed
    json.content @event.eventable.content.to_plain_text
  when Retro::Participant
    json.type "participant"
    json.id @event.eventable.id
    json.user_id @event.eventable.user_id
    json.user_name @event.eventable.user.name
    json.role @event.eventable.role
  end
end
