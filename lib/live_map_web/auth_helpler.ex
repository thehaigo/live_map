defmodule LiveMapWeb.AuthHelper do
  import Guardian.Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    Map.put(conn, :user_id, current_resource(conn).id)
  end
end
