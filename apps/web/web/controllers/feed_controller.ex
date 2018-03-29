defmodule Web.FeedController do
  use Web.Web, :controller
  alias Store.Feed

  def full_index(conn, params) do
    Feed
    |> GenServer.call({:index_all, params})
    |> send_response(conn)
  end

  def tenant_index(conn, params) do
    Feed
    |> GenServer.call({:index_for, params})
    |> send_response(conn)
  end

  defp send_response(result, conn) do
    conn
    |> put_status(200)
    |> json(result)
  end
end
