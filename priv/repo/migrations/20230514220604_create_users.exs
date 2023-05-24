defmodule Walkaround.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :text, null: false)
      add(:email, :text, null: false)
      add(:password_hash, :text)
      add(:confirmed_at, :utc_datetime)
      add(:last_visit_date, :date)
      timestamps()
    end

    create(unique_index(:users, [:email]))
  end
end
