defmodule LiveMap.Loggers.Map do
  use Ecto.Schema
  import Ecto.Changeset

  schema "maps" do
    field :description, :string
    field :name, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(map, attrs) do
    map
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
