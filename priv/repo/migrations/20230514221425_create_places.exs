defmodule Walkaround.Repo.Migrations.CreatePlaces do
  use Ecto.Migration

  def change do
    create table(:places) do
      add :slug, :text, null: false
      add(:user_id, references("users", on_delete: :delete_all), null: false)
      add(:name, :text, null: false)
      add(:description, :text)
      timestamps()
    end

    create(unique_index(:places, [:slug]))
    create(index(:places, [:user_id]))
  end
end
