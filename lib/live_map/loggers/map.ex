defmodule LiveMap.Loggers.Map do
  use Ecto.Schema
  import Ecto.Changeset

  schema "maps" do
    field :description, :string, default: ""
    field :name, :string

    belongs_to :user, LiveMap.Accounts.User
    has_many :points, LiveMap.Loggers.Point, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(map, attrs) do
    map
    |> cast(attrs, [:name, :description, :user_id])
    |> validate_required([:name, :user_id])
  end
end
