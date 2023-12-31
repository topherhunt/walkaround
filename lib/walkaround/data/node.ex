defmodule Walkaround.Data.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field(:slug, :string)
    belongs_to(:place, Walkaround.Data.Place)

    timestamps()
  end

  def changeset(place, attrs) do
    place
    |> cast(attrs, [:place_id])
    |> validate_required([:place_id])
    |> Walkaround.Repo.generate_slug()
  end
end
