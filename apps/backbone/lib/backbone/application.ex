defmodule Backbone.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Backbone.Supervisor.start_link()
  end
end
