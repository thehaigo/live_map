defmodule LiveMapWeb.MapLive.Show do
  use LiveMapWeb, :live_view

  alias LiveMap.Loggers
  alias LiveMapWeb.Presence

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    topic = "map:#{id}"
    Loggers.subscribe({:map, id})
    map = Loggers.get_map_with_points!(id)
    center = map.points |> Enum.take(1) |> Enum.map(fn p -> %{lat: p.lat, lng: p.lng} end)

    if Presence.list(topic) |> map_size() == 0 do
      map.points
      |> points_to_group_by_devices()
      |> track_all_devices(id)
    end

    devices = Presence.list_presence(topic)

    markers =
      Enum.map(devices, fn d ->
        %{uuid: d.uuid, lat: d.current_location.lat, lng: d.current_location.lng}
      end)

    {
      :ok,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:map, map)
      |> assign(:devices, Presence.list_presence("map:#{map.id}"))
      |> push_event("init_map", %{point: List.first(center), devices: markers})
    }
  end

  @impl true
  def handle_info({:created_point, point}, socket) do
    create_or_update_marker(point)
    device = Presence.get_presence("map:#{point.map_id}", point.device_id)

    {
      :noreply,
      socket
      |> push_event(
        "location_update",
        %{
          uuid: device.uuid,
          latlng: %{lat: point.lat, lng: point.lng},
          points: %{uuid: device.uuid, points: device.points} |> generate_geo_json("LineString"),
          viewing: device.viewing,
          tracking: device.tracking
        }
      )
    }
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket = %{assigns: %{map: map}}) do
    {:noreply, assign(socket, devices: Presence.list_presence("map:#{map.id}"))}
  end

  @impl true
  def handle_event("track", %{"uuid" => uuid}, socket) do
    topic = "map:#{socket.assigns.map.id}"
    Presence.update_all_presence(self(), topic, %{tracking: false})
    Presence.update_presence(self(), topic, uuid, %{tracking: true})
    device = Presence.get_presence(topic, uuid)

    {
      :noreply,
      push_event(socket, "track_device", %{
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
    device = Presence.get_presence(topic, uuid)
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
    Enum.group_by(points, fn p -> {p.device_id, p.user_agent} end)
    |> Enum.map(fn {{device_id, user_agent}, logs} ->
      %{
        uuid: device_id,
        ua: user_agent,
        current: List.first(logs),
        points: logs |> Enum.map(fn p -> [p.lng, p.lat] end)
      }
    end)
  end

  defp generate_geo_json(device, type) do
    %{
      type: "Feature",
      properties: %{name: device.uuid <> type},
      geometry: %{type: type, coordinates: device.points}
    }
  end

  defp track_all_devices(devices, id) do
    Enum.each(devices, fn device ->
      track(device, id)
    end)
  end

  defp track(device, id) do
    Presence.track(
      self(),
      "map:#{id}",
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
  end

  defp create_or_update_marker(point) do
    topic = "map:#{point.map_id}"
    device = Presence.get_presence(topic, point.device_id)

    if device do
      points = [[point.lng, point.lat] | device.points]

      Presence.update_presence(
        self(),
        topic,
        point.device_id,
        %{current_location: point, points: points}
      )
    else
      track(
        %{
          uuid: point.device_id,
          ua: point.user_agent,
          current: point,
          points: [[point.lng, point.lat]]
        },
        point.map_id
      )
    end
  end
end
