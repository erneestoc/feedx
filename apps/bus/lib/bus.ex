defmodule Bus do
  @moduledoc """
  Documentation for Bus.
  """
  use Application

  def start(_type, _args) do
    Bus.Supervisor.start_link()
  end
end
