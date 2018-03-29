defmodule Web.CommentController do
  use Web.Web, :controller
  alias Backbone.Comments

  def index(conn, params) do
    Comments
    |> GenServer.call({:index, params})
    |> send_response(conn)
  end

  def create(conn, params) do
    Comments
    |> GenServer.call({:create, params})
    |> send_response(conn)
  end

  def update(conn, params) do
    Comments
    |> GenServer.call({:update, params})
    |> send_response(conn)
  end

  def delete(conn, params) do
    Comments
    |> GenServer.call({:delete, params})
    |> send_response(conn)
  end

  defp send_response({:ok, result}, conn) do
    conn
    |> put_status(200)
    |> json(result)
  end

  defp send_response({:error, result}, conn) do
    conn
    |> put_status(500)
    |> json(result)
  end

  defp send_response(result, conn) do
    conn
    |> put_status(200)
    |> json(result)
  end
end
