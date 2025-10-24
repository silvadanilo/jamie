defmodule Jamie.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :hashed_password, :string
      add :confirmed_at, :utc_datetime
      add :telegram_user_id, :bigint
      add :role, :string, null: false, default: "user"
      add :blocked, :boolean, default: false, null: false
      add :name, :string
      add :surname, :string
      add :phone, :string
      add :preferred_role, :string, default: "base"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:telegram_user_id], where: "telegram_user_id IS NOT NULL")
    create index(:users, [:role])
  end
end
