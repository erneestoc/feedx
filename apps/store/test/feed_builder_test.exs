defmodule FeedBuilderTest do
  use ExUnit.Case
  doctest Store.FeedBuilder
  alias Store.{FeedRepo, SourceRepo, FeedBuilder}

  setup_all do
    UserTestHelper.ddl()
    events = FeedTestHelper.create()
    %{events: events}
  end

  test "persist event", %{events: events} do
    event = List.first(events)
    {:ok, event} = FeedBuilder.build(event)
    assert is_number(event.tenant_id)
    assert is_binary(event.type)
  end

  test "update event", %{events: events} do

  end

  test "delete event", %{events: events} do

  end
end
