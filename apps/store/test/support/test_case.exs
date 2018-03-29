defmodule Store.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use ExUnit.Case
      alias Store.{FeedRepo, SourceRepo}
    end
  end

  setup tags do
    :ok
  end
end
