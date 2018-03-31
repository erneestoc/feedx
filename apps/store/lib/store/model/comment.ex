defmodule Store.Comment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @params ~w(content event_id user_id)a

  @derive {Poison.Encoder, only: [:content, :user_id, :event_id]}

  schema "comments" do
    field(:content, :string)
    field(:event_id, :integer)
    field(:user_id, :integer)
    timestamps()
  end

  def changeset(comment, params \\ %{}) do
    comment
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
