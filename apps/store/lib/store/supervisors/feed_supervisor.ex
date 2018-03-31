defmodule Store.FeedSupervisor do
  @moduledoc false
  use Supervisor
  alias Store.{FeedRepo, FeedBuilder, Feed}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    [
      supervisor(FeedRepo, []),
      worker(FeedBuilder, [[], [name: :feed_builder]]),
      worker(Feed, [[], [name: Feed]])
    ]
  end
end
