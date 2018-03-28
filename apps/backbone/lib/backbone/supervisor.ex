defmodule Backbone.Supervisor do
  use Supervisor
  alias Backbone.{Consumer, Feed}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    [
      worker(Consumer, [[], [name: Consumer]]),
      worker(Feed, [[], [name: Feed]])
    ]
  end
end
