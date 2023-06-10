defmodule Walkaround.Repo.Migrations.CreateViews do
  use Ecto.Migration

  def change do
    create table(:views) do
      add :slug, :text, null: false
      add(:node_id, references("nodes", on_delete: :delete_all), null: false)
      add(:linked_view_id, references("views", on_delete: :nilify_all))
      add(:position, :integer, null: false)
      add(:image, :text)
      add(:image_peek_up, :text)
      add(:image_peek_forward, :text)
      timestamps()
    end

    create(unique_index(:views, [:slug]))
    create(index(:views, [:node_id]))
  end
end
