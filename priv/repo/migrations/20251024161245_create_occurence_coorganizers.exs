defmodule Jamie.Repo.Migrations.CreateOccurenceCoorganizers do
  use Ecto.Migration

  def change do
    create table(:occurence_coorganizers, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :occurence_id, references(:occurences, on_delete: :delete_all, type: :binary_id),
        null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: true
      add :invited_email, :string, null: false
      add :invite_token, :string
      add :invite_token_expires_at, :utc_datetime
      add :accepted_at, :utc_datetime

      add :invited_by_id, references(:users, on_delete: :nilify_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:occurence_coorganizers, [:occurence_id])
    create index(:occurence_coorganizers, [:user_id])
    create index(:occurence_coorganizers, [:invite_token])

    create unique_index(:occurence_coorganizers, [:occurence_id, :user_id],
             where: "user_id IS NOT NULL"
           )

    create unique_index(:occurence_coorganizers, [:occurence_id, :invited_email],
             where: "user_id IS NULL AND accepted_at IS NULL"
           )
  end
end
