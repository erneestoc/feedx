defmodule Store.FeedRepo.Migrations.CreateEventsTable do
  use Ecto.Migration

  def change do
  	create table(:events) do
      add(:type, :string)
      add(:external_id, :integer)
      add(:user_id, :integer)
      add(:tenant_id, :integer)
      add(:content, :text)
      add(:data, :json)
      add(:date, :naive_datetime)

      timestamps()
  	end
  end
end
