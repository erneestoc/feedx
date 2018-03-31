defmodule Web.Broadcast do
  @moduledoc false
  use GenServer
  alias Web.Endpoint
  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:event, type, id, payload}, state) do
    event(type, id, payload)
    {:noreply, state}
  end

  defp event(type, id, payload) do
    Endpoint.broadcast("events:#{id}", type, payload)
    Endpoint.broadcast("events:all", type, payload)
  end

end