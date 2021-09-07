defmodule LiveMapWeb.MapsController do
  use LiveMapWeb, :controller

  def index(conn, params) do
    user = LiveMap.Accounts.get_user!(conn.user_id)
    LiveMapWeb.UserAuth.webview_login(conn, user, params)
  end
end
