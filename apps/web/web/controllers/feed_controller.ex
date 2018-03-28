defmodule Web.FeedController do
  use Web.Web, :controller

  def full_index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end

  def tenant_index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ok: true})
  end
end
