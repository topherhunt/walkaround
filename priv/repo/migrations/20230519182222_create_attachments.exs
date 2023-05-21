defmodule Walkaround.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments) do
      add :image, :string

      timestamps()
    end
  end
end
