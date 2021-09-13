defmodule LiveMap.Repo.Migrations.ModifyLatlngToFloat do
  use Ecto.Migration

  def change do
    alter table(:points) do
      modify :lat, :float
      modify :lng, :float
    end
  end
end
