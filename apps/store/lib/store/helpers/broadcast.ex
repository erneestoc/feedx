defmodule Store.Broadcast do
  @moduledoc false
  alias Web.Endpoint
  def event(type, id, payload) do
    Endpoint.broadcast("events:#{id}", type, payload)
    Endpoint.broadcast("events:all", type, payload)
  end
end