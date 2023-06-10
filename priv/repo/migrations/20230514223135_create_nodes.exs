defmodule Walkaround.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :slug, :text, null: false
      add(:place_id, references("places", on_delete: :delete_all), null: false)
      timestamps()
    end

    create(unique_index(:nodes, [:slug]))
    create(index(:nodes, [:place_id]))
  end
end
