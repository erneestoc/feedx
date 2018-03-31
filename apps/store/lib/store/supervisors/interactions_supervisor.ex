defmodule Store.InteractionsSupervisor do
  @moduledoc false
  use Supervisor
  alias Store.{Comments, Likes}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    cache_conf = Application.get_env(:store, :interactions_cache)

    [
      supervisor(ConCache, [
        cache_options(cache_conf),
        [name: :interactions_cache]
      ]),
      worker(Comments, [[], [name: Comments]]),
      worker(Likes, [[], [name: Likes]])
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
