defmodule FeedBuilderTest do
  use ExUnit.Case
  doctest Store.FeedBuilder
  alias Store.{FeedBuilder, FeedRepo, Event}

  setup_all do
    UserTestHelper.ddl()
    events = FeedTestHelper.create()
    %{events: events}
  end

  test "persist event", %{events: events} do
    event = List.first(events)
    {:ok, event} = GenServer.call(:feed_builder, {:build, event})
    assert is_number(event.tenant_id)
    assert is_binary(event.type)
  end

  test "update event", %{events: events} do
    event_map = Enum.at(events, 1)
    {:ok, event} = FeedBuilder.build(event_map)
    event_map = Map.put(event_map, "type", "update")
    event_map_internal = Map.put(event_map["event"], "content", "hello")
    event_map = Map.put(event_map, "event", event_map_internal)
    {:ok, event2} = FeedBuilder.build(event_map)
    assert event.id == event2.id
    assert event2.content == "hello"
  end

  test "delete event", %{events: events} do
    event_map = List.last(events)
    {:ok, event} = GenServer.call(:feed_builder, {:build, event_map})
    assert FeedRepo.get_by(Event, id: event.id) != nil
    event_map = Map.put(event_map, "type", "delete")
    {:ok, event} = GenServer.call(:feed_builder, {:build, event_map})
    assert FeedRepo.get_by(Event, id: event.id) == nil
  end
end
