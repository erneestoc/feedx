defmodule Store.FeedRepo.Migrations.CreateCommentsTable do
  use Ecto.Migration

  def change do
  	create table(:comments) do
      add(:content, :string)
      add(:event_id, :integer)
      timestamps()
  	end
  end
end
