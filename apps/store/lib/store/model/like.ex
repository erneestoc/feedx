defmodule Store.Like do
  @moduledoc false
  use Ecto.Schema

  schema "likes" do
    field(:user_id, :integer)
    field(:tenant_id, :integer)
    timestamps()
  end
end
