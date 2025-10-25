defmodule Jamie.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :occurence_id, references(:occurences, on_delete: :delete_all, type: :binary_id),
        null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :status, :string, null: false, default: "confirmed"
      add :role, :string, null: false, default: "base"
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:participants, [:occurence_id])
    create index(:participants, [:user_id])
    create unique_index(:participants, [:occurence_id, :user_id])
  end
end
