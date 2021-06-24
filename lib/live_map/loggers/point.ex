defmodule LiveMap.Loggers.Point do
  use Ecto.Schema
  import Ecto.Changeset

  schema "points" do
    field :lat, :decimal
    field :lng, :decimal
    field :user_id, :id

    belongs_to :map, LiveMap.Loggers.Map

    timestamps()
  end

  @doc false
  def changeset(point, attrs) do
    point
    |> cast(attrs, [:lat, :lng, :map_id, :user_id])
    |> validate_required([:lat, :lng, :map_id, :user_id])
  end
end
