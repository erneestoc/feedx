defmodule Web.EventsChannelTest do
  use Web.ChannelCase
  alias Store.{FeedBuilder, Comments}
  alias Web.EventsChannel
  setup_all do
    UserTestHelper.ddl()

    events =
      10
      |> FeedTestHelper.create()
      |> Enum.map(fn map ->
        {:ok, event} = FeedBuilder.build(map)
        {map, event}
      end)

    %{events: events}
  end

  test "broadcast update event to all", %{events: events} do
    {:ok, _, _socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventsChannel, "events:all")
    {event, _} = List.first(events)
    event = Map.put(event, "type", "update")
    FeedBuilder.build(event)
    assert_broadcast "update", %{event: _}
  end

  test "broadcast update event to one", %{events: events} do
    {map, event} = Enum.at(events, 1)
    {:ok, _, _socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventsChannel, "events:#{event.id}")
    map = Map.put(map, "type", "update")
    FeedBuilder.build(map)
    assert_broadcast "update", %{event: _}
  end

  test "event not received on wrong channel", %{events: events} do
    {map, event} = Enum.at(events, 2)
    {_, event2} = Enum.at(events, 3)
    {:ok, _, _socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventsChannel, "events:#{event2.id}")
    map = Map.put(map, "type", "update")
    FeedBuilder.build(map)
    refute_broadcast "update", %{event: _}
  end

  test "delete event broadcast", %{events: events} do
    {map, event} = Enum.at(events, 4)
    {:ok, _, _socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventsChannel, "events:#{event.id}")
    map = Map.put(map, "type", "delete")
    FeedBuilder.build(map)
    assert_broadcast "delete", %{event: _}
  end

  test "receive comment broadcast for event", %{events: events} do
    {map, event} = Enum.at(events, 5)
    {:ok, _, _socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventsChannel, "events:#{event.id}")
    GenServer.call(Comments, {:create, %{user_id: event.user_id,
      event_id: event.id,
      content: "Hello world"
    }})
    assert_broadcast "add_comment", %{comment: _, user: _}
  end

  test "receive comment delete for event", %{events: events} do
    {map, event} = Enum.at(events, 5)
    {:ok, _, _socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventsChannel, "events:#{event.id}")
    GenServer.call(Comments, {:create, %{user_id: event.user_id,
      event_id: event.id,
      content: "Hello world"
    }})
    assert_broadcast "add_comment", %{comment: comment, user: _}
    GenServer.call(Comments, {:delete, %{comment_id: comment.id}})
    assert_broadcast "remove_comment", %{comment: _, user: _}
  end

  test "broadcast like", %{events: events} do
    {map, event} = Enum.at(events, 1)
    {:ok, _, _socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventsChannel, "events:#{event.id}")
    map = Map.put(map, "type", "update")
    FeedBuilder.build(map)
    assert_broadcast "update", %{event: _}
  end

end
