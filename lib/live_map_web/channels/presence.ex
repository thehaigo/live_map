defmodule LiveMapWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence, otp_app: :live_map,
                        pubsub_server: LiveMap.PubSub

  alias LiveMapWeb.Presence

  def track_presence(pid, topic, key, payload) do
    Presence.track(pid, topic, key, payload)
  end

  def list_presence(topic) do
    topic
    |> Presence.list
    |> Enum.map(fn {_user_id, data} -> extract_metadata(data) end)
  end

  def update_presence(pid, topic, key, payload) do
    metas =
      Presence.get_by_key(topic, key)
      |> extract_metadata()
      |> Map.merge(payload)

    Presence.update(pid, topic, key, metas)
  end

  def update_all_presence(pid,topic,payload) do
    topic
    |> Presence.list
    |> Enum.each(fn {key, _data} -> update_presence(pid, topic, key, payload) end)
  end

  def get_paresence(topic, key) do
    Presence.get_by_key(topic, key)
    |> extract_metadata
  end

  def extract_metadata(data) do
    data |> Map.get(:metas) |> List.first
  end
end
