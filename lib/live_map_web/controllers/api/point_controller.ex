defmodule LiveMapWeb.Api.PointController do
  use LiveMapWeb, :controller

  alias LiveMap.Loggers
  alias LiveMap.Loggers.Point

  def create(conn, point_params) do
    req =
      conn.req_headers
      |> Enum.filter(fn {k,_v} -> Enum.member?(["uuid", "user-agent"], k) end)
      |> Map.new()
    point_params = Enum.into(point_params, %{
      "device_id" => req["uuid"],
      "user_agent" => req["user-agent"] |> URI.decode() |> String.split() |> List.first,
      "user_id" => conn.user_id
    })
    with {:ok, %Point{}} <- Loggers.create_point(point_params) do
      send_resp(conn, 200, "ok")
    end
  end
end
