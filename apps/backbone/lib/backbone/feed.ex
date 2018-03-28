defmodule Backbone.Feed do
  @moduledoc false
  use GenServer

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end
end
