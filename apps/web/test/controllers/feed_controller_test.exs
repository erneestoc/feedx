defmodule Web.FeedControllerTest do
  use Web.ConnCase
  alias Store.FeedBuilder
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

  test "retrieve feed for", %{events: events, conn: conn} do
    event = List.first(events)
    tenant_id = event.tenant_id
    conn = get conn, feed_path(conn, :tenant_index, event.tenant_id)
    response = json_response(conn, 200)
    assert is_list(response["events"])
    assert length(response["events"]) > 0
  end
end
