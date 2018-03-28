defmodule BackboneTest do
  use ExUnit.Case
  doctest Backbone

  test "greets the world" do
    assert Backbone.hello() == :world
  end
end
