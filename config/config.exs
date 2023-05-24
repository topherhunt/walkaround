# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

defmodule H do
  def env!(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")
end

# Automatically load sensitive environment variables for dev and test
if File.exists?("config/secrets.exs"), do: import_config("secrets.exs")

config :walkaround,
  ecto_repos: [Walkaround.Repo],
  # Don't reference Mix.env() anywhere else in the codebase.
  # Instead use Walkaround.Helpers.env().
  mix_env: Mix.env()

# Configures the endpoint
config :walkaround, WalkaroundWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: WalkaroundWeb.ErrorHTML, json: WalkaroundWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Walkaround.PubSub,
  live_view: [signing_salt: "RRlry7fr"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :walkaround, Walkaround.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# For arc and ex_aws config, see runtime.exs

# Configures Elixir's Logger
config :logger, :console,
  level: if(System.get_env("DEBUG") == "true", do: :debug, else: :info),
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# By default, sent emails are captured in a local process for later inspection.
# Example:
#   Walkaround.AdminEmails.unknown_heats() |> Walkaround.Mailer.deliver_now()
#   Bamboo.SentEmail.all() # => a list having one %Bamboo.Email{} struct
config :walkaround, Walkaround.Mailer, adapter: Bamboo.LocalAdapter

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
