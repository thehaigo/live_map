defmodule LiveMapWeb.MapLive.FormComponent do
  use LiveMapWeb, :live_component

  alias LiveMap.Loggers

  @impl true
  def update(%{map: map} = assigns, socket) do
    changeset = Loggers.change_map(map)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"map" => map_params}, socket) do
    changeset =
      socket.assigns.map
      |> Loggers.change_map(map_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"map" => map_params}, socket) do
    save_map(socket, socket.assigns.action, map_params)
  end

  defp save_map(socket, :edit, map_params) do
    case Loggers.update_map(socket.assigns.map, map_params) do
      {:ok, _map} ->
        {:noreply,
         socket
         |> put_flash(:info, "Map updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_map(socket, :new, map_params) do
    case Loggers.create_map(map_params) do
      {:ok, _map} ->
        {:noreply,
         socket
         |> put_flash(:info, "Map created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
