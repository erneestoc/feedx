defmodule Store do
  @moduledoc """
  Documentation for Store.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    Store.Supervisor.start_link()
  end
end
