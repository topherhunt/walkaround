defmodule Walkaround.Data.Place do
  use Ecto.Schema
  import Ecto.Changeset

  schema "places" do
    field(:description, :string)
    field(:name, :string)

    belongs_to(:user, Walkaround.Data.User)

    timestamps()
  end

  def changeset(place, attrs) do
    place
    |> cast(attrs, [:user_id, :name, :description])
    |> validate_required([:user_id, :name])
    |> validate_length(:name, max: 250)
  end
end
