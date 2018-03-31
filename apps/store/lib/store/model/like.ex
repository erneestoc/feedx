defmodule Store.Like do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @params ~w(user_id event_id tenant_id)a

  @derive {Poison.Encoder, only: [:tenant_id, :user_id, :event_id]}

  schema "likes" do
    field(:user_id, :integer)
    field(:tenant_id, :integer)
    field(:event_id, :integer)
    timestamps()
  end

  def changeset(like, params \\ %{}) do
    like
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
