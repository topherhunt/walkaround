defmodule Walkaround.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:slug, :text, null: false)
      add(:name, :text, null: false)
      add(:email, :text, null: false)
      add(:password_hash, :text)
      add(:confirmed_at, :utc_datetime)
      add(:last_visit_date, :date)
      timestamps()
    end

    create(unique_index(:users, [:slug]))
    create(unique_index(:users, [:email]))
  end
end
