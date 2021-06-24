defmodule LiveMap.Loggers.Point do
  use Ecto.Schema
  import Ecto.Changeset

  schema "points" do
    field :lat, :decimal
    field :lng, :decimal
    field :user_id, :id
    field :map_id, :id

    timestamps()
  end

  @doc false
  def changeset(point, attrs) do
    point
    |> cast(attrs, [:lat, :lng])
    |> validate_required([:lat, :lng])
  end
end
