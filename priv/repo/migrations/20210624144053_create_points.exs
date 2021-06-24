defmodule LiveMap.Repo.Migrations.CreatePoints do
  use Ecto.Migration

  def change do
    create table(:points) do
      add :lat, :decimal
      add :lng, :decimal
      add :user_id, references(:users, on_delete: :nothing)
      add :map_id, references(:maps, on_delete: :nothing)

      timestamps()
    end

    create index(:points, [:user_id])
    create index(:points, [:map_id])
  end
end
