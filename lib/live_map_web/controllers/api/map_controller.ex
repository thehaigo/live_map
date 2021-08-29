defmodule LiveMapWeb.Api.MapController do
  use LiveMapWeb, :controller

  alias LiveMap.Loggers

  def index(conn, _params) do
    render(conn, "index.json", maps: Loggers.list_maps(conn.user_id))
  end

  def create(conn, map_params \\ %{}) do
    with {:ok, %Loggers.Map{} = map } <- Loggers.create_map(
    Map.put(map_params, "user_id", conn.user_id)
    ) do
      conn |> render("show.json", map: map)
    end
  end

  def show(conn, %{ "id" => id }) do
    render(conn, "show.json", map: Loggers.get_map!(id))
  end
end
