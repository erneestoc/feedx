defmodule Backbone do
  @moduledoc """
  Documentation for Backbone.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    Backbone.Supervisor.start_link()
  end
end
