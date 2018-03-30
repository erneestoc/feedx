defmodule CommentsTest do
  use ExUnit.Case
  doctest Store
  alias Store.{FeedRepo, SourceRepo, FeedBuilder, Comments}

  setup_all do
    UserTestHelper.ddl()
    events = FeedTestHelper.create(10)
      |> Enum.map(fn params ->
        {:ok, event} = FeedBuilder.build(params)
        event
      end)
    %{events: events}
  end

  test "get comments summary empty", %{events: events} do
    event = List.first(events)
    comments = GenServer.call(Comments, {:summary, event.id})
    assert comments.count == 0
    assert comments.comments == []
  end
end
