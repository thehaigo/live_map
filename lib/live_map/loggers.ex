defmodule LiveMap.Loggers do
  @moduledoc """
  The Loggers context.
  """

  import Ecto.Query, warn: false
  alias LiveMap.Repo

  alias LiveMap.Loggers.Map
  alias LiveMap.Loggers.Point

  @doc """
  Returns the list of maps.

  ## Examples

      iex> list_maps()
      [%Map{}, ...]

  """
  def list_maps(user_id) do
    Map
    |> where([m], m.user_id == ^user_id)
    |> Repo.all
  end

  def list_maps do
    Repo.all(Map)
  end
  @doc """
  Gets a single map.

  Raises `Ecto.NoResultsError` if the Map does not exist.

  ## Examples

      iex> get_map!(123)
      %Map{}

      iex> get_map!(456)
      ** (Ecto.NoResultsError)

  """
  def get_map!(id), do: Repo.get!(Map, id)

  def get_map_with_points!(id) do
    Map
    |> preload(points: ^from(p in Point, order_by: [desc: p.inserted_at]))
    |> Repo.get!(id)
  end
  @doc """
  Creates a map.

  ## Examples

      iex> create_map(%{field: value})
      {:ok, %Map{}}

      iex> create_map(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_map(attrs \\ %{}) do
    %Map{}
    |> Map.changeset(attrs)
    |> Repo.insert()
  end


  def create_point(attrs \\ %{}) do
    %Point{}
    |> Point.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created_point)
  end
  @doc """
  Updates a map.

  ## Examples

      iex> update_map(map, %{field: new_value})
      {:ok, %Map{}}

      iex> update_map(map, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_map(%Map{} = map, attrs) do
    map
    |> Map.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a map.

  ## Examples

      iex> delete_map(map)
      {:ok, %Map{}}

      iex> delete_map(map)
      {:error, %Ecto.Changeset{}}

  """
  def delete_map(%Map{} = map) do
    Repo.delete(map)
  end

  def subscribe({:map, map_id}) do
    Phoenix.PubSub.subscribe(LiveMap.PubSub, "map:#{map_id}")
  end

  def broadcast({:ok, point}, :created_point = event) do
    Phoenix.PubSub.broadcast(LiveMap.PubSub, "map:#{point.map_id}", {event, point})
    {:ok, point}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking map changes.

  ## Examples

      iex> change_map(map)
      %Ecto.Changeset{data: %Map{}}

  """
  def change_map(%Map{} = map, attrs \\ %{}) do
    Map.changeset(map, attrs)
  end
end
