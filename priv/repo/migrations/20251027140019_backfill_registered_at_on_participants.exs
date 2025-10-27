defmodule Jamie.Repo.Migrations.BackfillRegisteredAtOnParticipants do
  use Ecto.Migration

  def up do
    execute "UPDATE participants SET registered_at = inserted_at WHERE registered_at IS NULL"
  end

  def down do
    # No need to undo
  end
end
