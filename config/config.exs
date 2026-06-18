# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

env_file = Path.expand("../.env", __DIR__)

if File.exists?(env_file) do
  env_file
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.each(fn line ->
    unless line == "" or String.starts_with?(line, "#") do
      case String.split(line, "=", parts: 2) do
        [key, value] -> System.put_env(String.trim(key), String.trim(value))
        _ -> :ok
      end
    end
  end)
end

config :catchup_chat_backend,
  ecto_repos: [CatchupChatBackend.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :catchup_chat_backend, CatchupChatBackendWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: CatchupChatBackendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CatchupChatBackend.PubSub,
  live_view: [signing_salt: "iqoYcFSk"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
