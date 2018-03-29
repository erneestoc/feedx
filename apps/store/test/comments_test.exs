defmodule CommentsTest do
  use ExUnit.Case
  doctest Store
  alias Store.{FeedRepo, SourceRepo}

  test "greets the world" do
    assert Store.hello() == :world
  end
end
