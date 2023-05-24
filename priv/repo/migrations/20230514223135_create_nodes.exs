defmodule Walkaround.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:place_id, references("places", type: :uuid, on_delete: :delete_all), null: false)
      timestamps()
    end
  end
end
