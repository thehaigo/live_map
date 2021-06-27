# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_map,
  ecto_repos: [LiveMap.Repo]

config :live_map, LiveMap.Guardian,
  issuer: "live_map",
  secret_key: "add generated secret by mix guardian.gen.secret"

# Configures the endpoint
config :live_map, LiveMapWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UQ12yViO3LayXIzh8De/4Q7AhxprZqpfp0Kbehw2zx6FdbgZS1eiYd3wNGf7HHdm",
  render_errors: [view: LiveMapWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: LiveMap.PubSub,
  live_view: [signing_salt: "z/m99Z5+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
