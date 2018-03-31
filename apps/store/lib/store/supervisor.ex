defmodule Store.Supervisor do
  @moduledoc false
  use Supervisor
  alias Store.{SourceRepo, FeedRepo, Comments, FeedBuilder, Feed, Users, Likes}

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
      supervisor(ConCache, [[], [name: :user_cache]]),
      worker(Users, [[], [name: Users]]),
      worker(FeedBuilder, [[], [name: FeedBuilder]]),
      worker(Feed, [[], [name: Feed]]),
      worker(Comments, [[], [name: Comments]]),
      worker(Likes, [[], [name: Likes]])
    ]
  end
end
