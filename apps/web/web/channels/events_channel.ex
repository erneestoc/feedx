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

  def handle_info({:after_join, _msg}, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end
end
