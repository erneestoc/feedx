defmodule Web.EventControllerTest do
  use Web.ConnCase
  alias Store.FeedBuilder
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

  test "GET /feed/:tenant_id/events/:event_id/likes", %{conn: conn, events: events} do
    event = List.first events
    path = event_path(conn, :index, event.tenant_id, event.id)
    conn = get conn, path, %{"user_id" => event.user_id}
    assert json_response(conn, 200)
  end

  test "GET /feed/:tenant_id/events/:event_id/like", %{conn: conn, events: events} do
    event = List.first events
    path = event_path(conn, :like, event.tenant_id, event.id)
    conn = get conn, path, %{"user_id" => event.user_id}
    assert json_response(conn, 200)
  end

  test "GET /feed/:tenant_id/events/:event_id/unlike", %{conn: conn, events: events} do
    event = List.first events
    path = event_path(conn, :unlike, event.tenant_id, event.id)
    conn = get conn, path, %{"user_id" => event.user_id}
    assert json_response(conn, 200)
  end
end
