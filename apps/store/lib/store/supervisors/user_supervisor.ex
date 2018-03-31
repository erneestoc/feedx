defmodule Store.UserSupervisor do
  @moduledoc false
  use Supervisor
  alias Store.{Users, SourceRepo}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    cache_conf = Application.get_env(:store, :user_cache)

    [
      supervisor(SourceRepo, []),
      supervisor(ConCache, [cache_options(cache_conf), [name: :user_cache]]),
      worker(Users, [[], [name: Users]])
    ]
  end

  defp cache_options(nil), do: []

  defp cache_options(params) do
    if params[:ttl] do
      touch = params[:touch_on_read] || true
      global = params[:global_ttl] || 5
      check_interval = params[:check_interval] || 1

      [
        ttl_check_interval: :timer.seconds(check_interval),
        global_ttl: :timer.seconds(global),
        touch_on_read: touch
      ]
    else
      []
    end
  end
end
