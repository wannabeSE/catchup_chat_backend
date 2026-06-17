defmodule CatchupChatBackend.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :last_coordinates, :map
      add :is_admin, :boolean, default: false, null: false
    end
  end
end
