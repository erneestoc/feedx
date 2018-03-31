defmodule Web do
  @moduledoc false
  use Application
  alias Web.{Endpoint, Broadcast}

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Endpoint, []),
      worker(Broadcast, [[], [name: :ws_broadcast]])
    ]

    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
