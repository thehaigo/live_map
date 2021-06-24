defmodule LiveMapWeb.MapLive.Index do
  use LiveMapWeb, :live_view

  alias LiveMap.Loggers
  alias LiveMap.Loggers.Map

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :maps, list_maps())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Map")
    |> assign(:map, Loggers.get_map!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Map")
    |> assign(:map, %Map{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Maps")
    |> assign(:map, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    map = Loggers.get_map!(id)
    {:ok, _} = Loggers.delete_map(map)

    {:noreply, assign(socket, :maps, list_maps())}
  end

  defp list_maps do
    Loggers.list_maps()
  end
end
