defmodule Web.CommentControllerTest do
  use Web.ConnCase
  alias Store.{FeedBuilder, Comment, FeedRepo}
  setup do
    UserTestHelper.ddl()

    events =
      1
      |> FeedTestHelper.create()
      |> Enum.map(fn params ->
        {:ok, event} = FeedBuilder.build(params)
        event
      end)

    %{events: events}
  end
  test "GET  /feed/:tenant_id/events/:event_id/comments", %{conn: conn, events: events} do
    event = List.first events
    conn = get conn, comment_path(conn, :index, event.tenant_id, event.id)
    response = json_response(conn, 200)
    assert response == []
  end

  test "POST  /feed/:tenant_id/events/:event_id/comments", %{conn: conn, events: events} do
    event = List.first events
    path = comment_path(conn, :index, event.tenant_id, event.id)
    conn = post conn, path, %{"content" => "hola", "user_id" => event.user_id}
    response = json_response(conn, 200)
    assert response["user_id"] == event.user_id
    assert response["content"] == "hola"
  end

  test "PUT  /feed/:tenant_id/events/:event_id/comments/:comment_id", %{conn: conn, events: events} do
    event = List.first events
    comment = FeedRepo.insert! %Comment{
      user_id: event.user_id,
      content: "holamundo",
      event_id: event.id
    }
    path = comment_path(conn, :update, event.tenant_id, event.id, comment.id)
    conn = put conn, path, %{"content" => "hola", "user_id" => event.user_id}
    response = json_response(conn, 200)
    assert response["user_id"] == event.user_id
    assert response["content"] == "hola"
    assert response["id"] == comment.id
  end

  test "PATCH  /feed/:tenant_id/events/:event_id/comments/:comment_id", %{conn: conn, events: events} do
    event = List.first events
    comment = FeedRepo.insert! %Comment{
      user_id: event.user_id,
      content: "holamundo",
      event_id: event.id
    }
    path = comment_path(conn, :update, event.tenant_id, event.id, comment.id)
    conn = patch conn, path, %{"content" => "hola", "user_id" => event.user_id}
    response = json_response(conn, 200)
    assert response["user_id"] == event.user_id
    assert response["content"] == "hola"
    assert response["id"] == comment.id
  end

  test "DELETE  /feed/:tenant_id/events/:event_id/comments/:comment_id", %{conn: conn, events: events} do
    event = List.first events
    comment = FeedRepo.insert! %Comment{
      user_id: event.user_id,
      content: "holamundo",
      event_id: event.id
    }
    path = comment_path(conn, :update, event.tenant_id, event.id, comment.id)
    conn = delete conn, path, %{"content" => "hola", "user_id" => event.user_id}
    response = json_response(conn, 200)
    assert FeedRepo.get_by(Comment, id: response["id"]) == nil
  end
end
