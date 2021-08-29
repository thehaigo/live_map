defmodule LiveMapWeb.Api.MapView do
  use LiveMapWeb, :view
  alias LiveMapWeb.Api.MapView

  def render("index.json", %{maps: maps}) do
    render_many(maps, MapView, "map.json")
  end

  def render("show.json", %{map: map}) do
    render_one(map, MapView, "map.json")
  end

  def render("map.json", %{map: map}) do
    %{
      id: map.id,
      name: map.name,
      description: map.description
    }
  end
end
