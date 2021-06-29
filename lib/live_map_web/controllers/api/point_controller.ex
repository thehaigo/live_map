defmodule LiveMapWeb.Api.PointController do
  use LiveMapWeb, :controller

  alias LiveMap.Loggers
  alias LiveMap.Loggers.Point

  def create(conn, point_params) do
    with {:ok, %Point{}} <- Loggers.create_point(
      Map.put(point_params, "user_id", conn.user_id)
    ) do
      send_resp(conn, 200, "ok")
    end
  end
end
