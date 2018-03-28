defmodule Store.Supervisor do
  use Supervisor
  alias Store.{SourceRepo, FeedRepo}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    [
      supervisor(SourceRepo, []),
      supervisor(FeedRepo, []),
      supervisor(ConCache, [[], [name: :feed_cache]])
    ]
  end
end
