defmodule LiveMapWeb.MapLive.Map do
  use LiveMapWeb, :live_view

  alias LiveMap.Loggers

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Loggers.subscribe({:map, id})
    {:ok, socket}
  end

  @impl true
  def handle_info({:created_point, point}, socket) do
    {
      :noreply,
      socket
      |> update(:points, fn points -> [point | points] |> Enum.reverse end)
      |> push_event("created_point", %{ point: %{ lat: point.lat, lng: point.lng} })
    }
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

  @impl true
  def handle_event("track", _, socket) do
    IO.inspect("track")
    {:noreply, push_event(socket, "track", %{})}
  end

  @impl true
  def handle_event("location", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Map"
end
