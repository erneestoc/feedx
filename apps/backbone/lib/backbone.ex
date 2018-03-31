defmodule Backbone do
  @moduledoc """
  Documentation for Backbone.
  """
  use Application

  def start(_type, _args) do
    Backbone.Supervisor.start_link()
  end
end
