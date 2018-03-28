defmodule Backbone.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Backbone.Supervisor.start_link()
  end
end
