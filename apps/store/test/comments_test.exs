defmodule CommentsTest do
  use ExUnit.Case
  doctest Store.Comments
  alias Store.{FeedBuilder, FeedRepo, Comments, Comment}

  setup_all do
    UserTestHelper.ddl()
    :ok
  end

  test "get comments summary empty" do
    {:ok, event} = create_event()

    comments = GenServer.call(Comments, {:preview, event.id})
    assert comments.count == 0
    assert comments.comments == []
  end

  test "get comments summary" do
    {:ok, event} = create_event()

    users = FeedTestHelper.create_10_users()

    1..10
    |> Enum.map(fn _ -> create_comment(event, users) end)

    comments = GenServer.call(Comments, {:preview, event.id})
    assert comments.count == 10
    assert length(comments.comments) == 3
  end

  test "get full comments" do
    {:ok, event} = create_event()

    users = FeedTestHelper.create_10_users()

    1..100
    |> Enum.map(fn _ -> create_comment(event, users) end)

    comments = GenServer.call(Comments, {:index, %{"event_id" => event.id}})
    assert length(comments) == 100
  end

  test "update comment" do
    {user_id, _, _} = UserTestHelper.generate_user()
    {:ok, event} = create_event()

    {:ok, comment} =
      GenServer.call(
        Comments,
        {:create, %{"event_id" => event.id, "user_id" => user_id, "content" => "holamundo"}}
      )

    {:ok, _} =
      GenServer.call(
        Comments,
        {:update, %{"comment_id" => comment.id, "content" => "hola2"}}
      )

    comment = FeedRepo.get_by(Comment, id: comment.id)
    assert comment.content == "hola2"
  end

  test "delete comment" do
    {user_id, _, _} = UserTestHelper.generate_user()
    {:ok, event} = create_event()

    {:ok, comment} =
      GenServer.call(
        Comments,
        {:create, %{"event_id" => event.id, "user_id" => user_id, "content" => "holamundo"}}
      )

    {:ok, _} =
      GenServer.call(
        Comments,
        {:delete, %{"comment_id" => comment.id}}
      )

    comment = FeedRepo.get_by(Comment, id: comment.id)
    assert comment == nil
  end

  defp create_comment(event, users) do
    x = :rand.uniform(10)
    {user_id, _, _} = Enum.at(users, x)

    GenServer.call(
      Comments,
      {:create, %{"event_id" => event.id, "user_id" => user_id, "content" => "holamundo"}}
    )
  end

  defp create_event do
    1
    |> FeedTestHelper.create()
    |> List.first()
    |> FeedBuilder.build()
  end
end
