defmodule Store.FeedRepo.Migrations.CreateLikesTable do
  use Ecto.Migration

  def change do
  	create table(:likes) do
  	  add(:tenant_id, :integer)
      add(:user_id, :integer)
      add(:event_id, :integer)
      timestamps()
  	end
  end
end
