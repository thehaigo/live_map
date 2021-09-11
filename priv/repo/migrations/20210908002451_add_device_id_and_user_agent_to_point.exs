defmodule LiveMap.Repo.Migrations.AddDeviceIdAndUserAgentToPoint do
  use Ecto.Migration

  def change do
    alter table(:points) do
      add :device_id, :string, default: ""
      add :user_agent, :string, default: ""
    end
  end
end
