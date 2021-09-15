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
    |> validate_uuid(:device_id)
  end

  defp validate_uuid(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn field, value ->
      case UUID.info(value) do
        {:ok, _info} -> []
        {:error, reason} -> [{field, reason}]
      end
    end)
  end
end
