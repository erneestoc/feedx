defmodule FeedTest do
  use ExUnit.Case
  doctest Store.Feed
  alias Store.{FeedRepo, SourceRepo, FeedBuilder, Feed}

  setup_all do
    UserTestHelper.ddl()
    events = FeedTestHelper.create()
      |> Enum.map(fn params ->
        {:ok, event} = FeedBuilder.build(params)
        event
      end)
    %{events: events}
  end

  test "retrieve feed for", %{events: events} do
    event = List.first(events)
    tenant_id = event.tenant_id
    results = Feed.index_for(%{tenant_id: event.tenant_id})
    
    assert is_list(results.events)
    assert is_number(results.last_number)

    assert is_number(List.first(results.events).comments.count)
    assert is_list(List.first(results.events).comments.data)

    Enum.map(results.events, fn event ->
      assert event.tenant_id == tenant_id
    end)
  end

  test "retrieve empty feed" do
    event = List.first(events)
    results = Feed.index_for(%{tenant_id: event.tenant_id})
    assert results.events == []
    assert is_nil(results.last_number)
  end
end
