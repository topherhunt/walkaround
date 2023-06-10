defmodule Walkaround.Repo do
  use Ecto.Repo,
    otp_app: :walkaround,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  def count(query), do: query |> select([t], count(t.id)) |> one()
  def any?(query), do: count(query) >= 1
  def first(query), do: query |> limit(1) |> one()
  def first!(query), do: query |> limit(1) |> one!()

  # Unwraps the result tuple and blows up if an error occurred.
  def unwrap!(result) do
    case result do
      {:ok, struct} -> struct
      {:error, changeset} -> raise Ecto.InvalidChangesetError, changeset: changeset
    end
  end
end
