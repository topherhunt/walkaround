defmodule Walkaround.Repo.Migrations.CreatePlaces do
  use Ecto.Migration

  def change do
    create table(:places, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references("users", type: :uuid, on_delete: :delete_all), null: false)
      add(:name, :text, null: false)
      add(:description, :text)
      timestamps()
    end
  end
end
