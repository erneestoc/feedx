defmodule Web.EventController do
  use Web.Web, :controller

  def show(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end

  def like(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end

  def unlike(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end
end
