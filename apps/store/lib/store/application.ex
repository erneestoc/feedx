defmodule Store.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Store.Supervisor.start_link()
  end
end
