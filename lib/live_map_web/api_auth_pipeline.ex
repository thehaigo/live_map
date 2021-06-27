defmodule LiveMapWeb.ApiAuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :live_map,
    module: LiveMap.Guardian,
    error_handler: LiveMapWeb.ApiAuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
