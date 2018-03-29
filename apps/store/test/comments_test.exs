defmodule CommentsTest do
  use ExUnit.Case
  doctest Store
  alias Store.{FeedRepo, SourceRepo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FeedRepo)
  end

  test "greets the world" do
    assert Store.hello() == :world
  end
end
