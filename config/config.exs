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
  ecto_repos: [Walkaround.Repo]

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

# See https://github.com/stavro/arc#configuration
config :arc,
  storage: Arc.Storage.S3,
  bucket: H.env!("AWS_S3_BUCKET")

config :ex_aws,
  # debug_requests: true,
  access_key_id: H.env!("AWS_ACCESS_KEY_ID"),
  secret_access_key: H.env!("AWS_SECRET_ACCESS_KEY"),
  region: H.env!("AWS_S3_REGION"),
  s3: [
    scheme: "https://",
    host: "s3.#{H.env!("AWS_S3_REGION")}.amazonaws.com",
    region: H.env!("AWS_S3_REGION")
  ]

# Configures Elixir's Logger
config :logger, :console,
  level: if(System.get_env("DEBUG") == "true", do: :debug, else: :info),
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
