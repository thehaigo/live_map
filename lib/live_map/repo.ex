defmodule LiveMap.Repo do
  use Ecto.Repo,
    otp_app: :live_map,
    adapter: Ecto.Adapters.Postgres
end
