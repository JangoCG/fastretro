require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "create event" do
    event = Event.create!(
      account: accounts(:one),
      retro: retros(:one),
      creator: users(:one),
      action: "retro.created",
      eventable: retros(:one)
    )
    assert event.persisted?
  end

  test "action inquiry" do
    event = events(:retro_created)
    assert_equal "retro.created", event.action.to_s
    assert event.action == "retro.created"
  end
end
