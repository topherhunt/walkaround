defmodule Walkaround.Repo.Migrations.CreateViews do
  use Ecto.Migration

  def change do
    create table(:views, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:node_id, references("nodes", type: :uuid, on_delete: :delete_all), null: false)
      add(:linked_view_id, references("views", type: :uuid, on_delete: :nilify_all))
      add(:position, :integer, null: false)
      add(:image, :text)
      add(:image_peek_up, :text)
      add(:image_peek_forward, :text)
      timestamps()
    end
  end
end
