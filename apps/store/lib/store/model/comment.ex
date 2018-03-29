defmodule Store.Comment do
  @moduledoc false
  use Ecto.Schema

  schema "comments" do
    field(:content, :string)
    field(:event_id, :integer)
    timestamps()
  end
end
