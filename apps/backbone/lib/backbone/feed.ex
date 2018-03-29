defmodule Backbone.Feed do
  @moduledoc false
  use GenServer

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:index_all, params}, _from, state) do
  	send_result(nil, state)
  end

  def handle_call({:index_for, params}, _from, state) do
  	send_result(nil, state)
  end

  defp send_result(result, state), do: {:reply, result, state}
end
