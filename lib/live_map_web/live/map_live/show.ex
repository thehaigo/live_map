defmodule LiveMapWeb.MapLive.Show do
  use LiveMapWeb, :live_view

  alias LiveMap.Loggers
  alias LiveMapWeb.Presence

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Loggers.subscribe({:map, id})
    map = Loggers.get_map_with_points!(id)
    center = map.points |> Enum.take(1) |> Enum.map(fn p -> %{lat: p.lat, lng: p.lng} end)
    devices = points_to_group_by_devices(map.points)
    # markerはgeo jsonではなく window.markers で管理する
    markers =
      devices
      |> Enum.map(fn d ->
        d |>
        Map.put(
          :points,
          Enum.take(d.points,1)
          |> List.first
        )
        |> generate_geo_json("Point")
      end)
    track_all_devices(devices, map)
    {
      :ok,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:map, map)
      |> assign(:devices, Presence.list_presence("map:#{map.id}"))
      |> push_event("init_map",%{point: List.first(center), devices: markers})
    }
  end

  @impl true
  def handle_info({:created_point, point}, socket) do
    topic = "map:#{socket.assigns.map.id}"
    device = Presence.get_paresence(topic, point.device_id)
    points = [[point.lng, point.lat]|device.points]
    Presence.update_presence(
      self(),
      topic,
      point.device_id,
      %{
        current_location: point,
        points: points
      })
    {
      :noreply,
      socket
      |> push_event("location_update",
        %{
          uuid: point.device_id,
          latlng: %{lat: point.lat,lng: point.lng},
          point:
            %{uuid: point.device_id, points: [point.lng, point.lat]}
            |> generate_geo_json("Point"),
          points: %{uuid: point.device_id, points: points} |> generate_geo_json("LineString"),
          viewing: device.viewing,
          tracking: device.tracking
        })
    }
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket = %{ assigns: %{map: map}}) do
    {:noreply, assign(socket, devices: Presence.list_presence("map:#{map.id}"))}
  end

  @impl true
  def handle_event("track", %{"uuid" => uuid}, socket) do
    topic = "map:#{socket.assigns.map.id}"
    Presence.update_all_presence(self(),topic, %{tracking: false})
    Presence.update_presence(self(), topic, uuid, %{tracking: true})
    device = Presence.get_paresence(topic,uuid)
    {
      :noreply,
      push_event(socket,"track_device", %{
        point: %{
          lat: device.current_location.lat,
          lng: device.current_location.lng
        }
      })
    }
  end

  @impl true
  def handle_event("viewing", %{"uuid" => uuid}, socket) do
    topic = "map:#{socket.assigns.map.id}"
    device = Presence.get_paresence(topic, uuid)
    Presence.update_presence(self(), topic, uuid, %{viewing: !device.viewing})

    {
      :noreply,
      push_event(
        socket,
        "view_device_log",
        %{
          uuid: device.uuid,
          json: generate_geo_json(device, "LineString"),
          viewing: !device.viewing
        }
      )
    }
  end

  defp page_title(:show), do: "Show Map"
  defp page_title(:edit), do: "Edit Map"

  defp points_to_group_by_devices(points) do
    Enum.group_by(points, fn p -> { p.device_id, p.user_agent} end)
    |> Map.to_list()
    |> Enum.map(fn {{device_id, user_agent}, logs} ->
        %{
          uuid: device_id,
          ua: user_agent,
          current: List.first(logs),
          points: Enum.map(logs, fn p -> [p.lng,p.lat] end)
        }
      end)
  end

  defp generate_geo_json(device, type) do
    %{
        type: "Feature",
        properties: %{ name: device.uuid <> type },
        geometry: %{type: type, coordinates: device.points}
    }
  end

  defp track_all_devices(devices, map) do
    Enum.each(devices, fn device ->
      Presence.track_presence(
        self(),
        "map:#{map.id}",
        device.uuid,
        %{
          name: device.ua,
          uuid: device.uuid,
          current_location: device.current,
          tracking: false,
          viewing: false,
          points: device.points
        }
      )
    end)
  end
end
