defmodule Walkaround.Repo do
  use Ecto.Repo,
    otp_app: :walkaround,
    adapter: Ecto.Adapters.Postgres
end
