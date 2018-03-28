defmodule Web.CommentController do
  use Web.Web, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end

  def create(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end

  def update(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end

  def delete(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end
end
