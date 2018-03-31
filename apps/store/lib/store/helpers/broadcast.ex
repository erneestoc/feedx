defmodule Store.Broadcast do
  @moduledoc false

  def event(type, id, payload) do
    GenServer.cast(:ws_broadcast, {:event, type, id, payload})
  end
end
