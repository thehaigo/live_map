defmodule LiveMap.Loggers.Point do
  use Ecto.Schema
  import Ecto.Changeset

  schema "points" do
    field :lat, :float
    field :lng, :float
    field :device_id, :string
    field :user_agent, :string
    field :user_id, :id

    belongs_to :map, LiveMap.Loggers.Map

    timestamps()
  end

  @doc false
  def changeset(point, attrs) do
    point
    |> cast(attrs, [:lat, :lng, :map_id, :user_id, :device_id, :user_agent])
    |> validate_required([:lat, :lng, :map_id, :user_id, :device_id, :user_agent])
  end
end
