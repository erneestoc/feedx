defmodule LikeTest do
  use ExUnit.Case
  alias Store.{FeedRepo, SourceRepo, FeedBuilder, Likes}

  setup_all do
    UserTestHelper.ddl()
    :ok
  end

  test "get likes summary empty" do
    {:ok, event} = create_event()
    preview = GenServer.call(Likes, {:preview, event.id})
    assert preview.count == 0
    assert preview.likers == []
    assert preview.you == false
  end

  test "get likes summary" do
    {:ok, event} = create_event()
    create_likes_for(event)
    preview = GenServer.call(Likes, {:preview, event.id})
    assert preview.count == 10
    assert length(preview.likers) == 3
    assert preview.you == false
  end

  test "get all likers list" do
    {:ok, event} = create_event()
    create_likes_for(event)
    likers = GenServer.call(Likes, {:index, %{event_id: event.id}})
    assert length(likers) == 10
  end

  defp create_event do
    FeedTestHelper.create(1)
    |> List.first
    |> FeedBuilder.build()
  end

  defp create_likes_for(event) do
    users = FeedTestHelper.create_10_users()
    1..10
    |> Enum.map(fn _ -> create_like(event, users) end)
  end

  defp create_like(event, users) do
    num = :rand.uniform(10)
    {user, _, _} = Enum.at(users, num)
    GenServer.call(Likes, {:create, %{
      user_id: user,
      event_id: event.id,
      tenant_id: 0
    }})
  end
end
