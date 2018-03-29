defmodule Store.Comments do
  @moduledoc false
  use GenServer

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:index, params}, _from, state) do
    send_result(nil, state)
  end

  def handle_call({:create, params}, _from, state) do
    send_result(nil, state)
  end

  def handle_call({:update, params}, _from, state) do
    send_result(nil, state)
  end

  def handle_call({:delete, params}, _from, state) do
    send_result(nil, state)
  end

  defp send_result(result, state), do: {:reply, result, state}
end
