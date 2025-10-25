defmodule Jamie.Repo.Migrations.AddIsCreatorToOccurenceCoorganizers do
  use Ecto.Migration

  def change do
    alter table(:occurence_coorganizers) do
      add :is_creator, :boolean, default: false, null: false
    end

    # Add index for faster queries
    create index(:occurence_coorganizers, [:occurence_id, :user_id, :is_creator])
  end
end
