defmodule Web.EventController do
  use Web.Web, :controller
  alias Store.Likes

  def index(conn, params) do
    Likes
    |> GenServer.call({:index, params})
    |> send_response(conn)
  end

  def like(conn, params) do
    Likes
    |> GenServer.call({:create, params})
    |> send_response(conn)
  end

  def unlike(conn, params) do
    Likes
    |> GenServer.call({:delete, params})
    |> send_response(conn)
  end

  defp send_response({:ok, result}, conn) do
    conn
    |> put_status(200)
    |> json(result)
  end

  defp send_response({:error, reason}, conn) do
    conn
    |> put_status(500)
    |> json(reason)
  end

  defp send_response(result, conn) do
    conn
    |> put_status(200)
    |> json(result)
  end
end
