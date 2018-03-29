defmodule Backbone.Supervisor do
  @moduledoc false
  use Supervisor
  alias Backbone.Consumer

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    [
      worker(Consumer, [[], [name: Consumer]])
    ]
  end
end
