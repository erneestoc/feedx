defmodule Store.Event do
  use Ecto.Schema

  schema "events" do
    field(:type, :string)
    field(:external_id, :integer)
    field(:user_id, :integer)
    field(:tenant_id, :integer)
    field(:content, :string)
    field(:data, :map)
    field(:date, Ecto.DateTime)

    timestamps()
  end
end