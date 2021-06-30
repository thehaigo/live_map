defmodule LiveMapWeb.MapLive.Show do
  use LiveMapWeb, :live_view

  alias LiveMap.Loggers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    map = Loggers.get_map_with_points!(id)
    points = Enum.map(map.points, fn p -> %{lat: p.lat, lng: p.lng} end)
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:map, map)
      |> assign(:points, points)
      |> push_event("init_map", %{points: points})
    }
  end

  defp page_title(:show), do: "Show Map"
  defp page_title(:edit), do: "Edit Map"
end
