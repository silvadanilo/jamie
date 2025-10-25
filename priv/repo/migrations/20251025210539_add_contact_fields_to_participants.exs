defmodule Jamie.Repo.Migrations.AddContactFieldsToParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :name, :string
      add :surname, :string
      add :phone, :string
      add :email, :string
      modify :user_id, :binary_id, null: true
    end

    create unique_index(:participants, [:occurence_id, :email],
             name: :participants_occurence_id_email_index,
             where: "email IS NOT NULL"
           )
  end
end
