defmodule Web.EventsChannel do
  @moduledoc false
  use Phoenix.Channel
  require Logger

  def join("events:all", _message, socket) do
    {:ok, socket}
  end

  def join("events:" <> _tenant_id, _message, socket) do
    {:ok, socket}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    _ = Logger.debug fn -> "> leave #{inspect reason}" end
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end
end
