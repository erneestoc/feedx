defmodule Web.EventController do
  use Web.Web, :controller
  alias Store.Feed

  def show(conn, params) do
    Feed
    |> GenServer.call({:show, params})
    |> send_response(conn)
  end

  def like(conn, params) do
    Feed
    |> GenServer.call({:like, params})
    |> send_response(conn)
  end

  def unlike(conn, params) do
    Feed
    |> GenServer.call({:unlike, params})
    |> send_response(conn)
  end

  defp send_response(result, conn) do
    conn
    |> put_status(200)
    |> json(result)
  end
end
