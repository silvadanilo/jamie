defmodule Jamie.Repo.Migrations.AllowNullInvitedByIdForCreators do
  use Ecto.Migration

  def up do
    # Drop the existing foreign key constraint
    execute "ALTER TABLE occurence_coorganizers DROP CONSTRAINT occurence_coorganizers_invited_by_id_fkey"

    # Modify the column to allow NULL
    alter table(:occurence_coorganizers) do
      modify :invited_by_id, :binary_id, null: true
      modify :invited_email, :string, null: true
    end

    # Re-add the foreign key constraint
    execute "ALTER TABLE occurence_coorganizers ADD CONSTRAINT occurence_coorganizers_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES users(id)"
  end

  def down do
    # Drop the foreign key
    execute "ALTER TABLE occurence_coorganizers DROP CONSTRAINT occurence_coorganizers_invited_by_id_fkey"

    # Modify the column back to NOT NULL
    alter table(:occurence_coorganizers) do
      modify :invited_by_id, :binary_id, null: false
      modify :invited_email, :string, null: false
    end

    # Re-add the foreign key constraint
    execute "ALTER TABLE occurence_coorganizers ADD CONSTRAINT occurence_coorganizers_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES users(id)"
  end
end
