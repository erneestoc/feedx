defmodule FeedTest do
  use ExUnit.Case
  doctest Store.Feed
  alias Store.{FeedBuilder, Feed}

  setup_all do
    UserTestHelper.ddl()

    events =
      10
      |> FeedTestHelper.create()
      |> Enum.map(fn params ->
        {:ok, event} = FeedBuilder.build(params)
        event
      end)

    %{events: events}
  end

  test "retrieve feed for", %{events: events} do
    event = List.first(events)
    tenant_id = event.tenant_id
    results = GenServer.call(Feed, {:index_for, %{"tenant_id" => event.tenant_id}})

    assert is_list(results.events)

    assert is_number(List.first(results.events).comments.count)
    assert is_list(List.first(results.events).comments.comments)

    Enum.map(results.events, fn event ->
      assert event.event.tenant_id == tenant_id
    end)
  end

  test "retrieve empty feed", %{events: _events} do
    tenant_id = :rand.uniform(1_000_000_000)
    results = GenServer.call(Feed, {:index_for, %{"tenant_id" => tenant_id}})
    assert results.events == []
    assert is_nil(results.pagination.after)
  end
end
