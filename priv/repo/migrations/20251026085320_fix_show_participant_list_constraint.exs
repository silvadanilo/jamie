defmodule Jamie.Repo.Migrations.FixShowParticipantListConstraint do
  use Ecto.Migration

  def up do
    # Fix any existing records where show_partecipant_list is true but is_private is false
    execute """
      UPDATE occurences
      SET show_partecipant_list = false
      WHERE show_partecipant_list = true
        AND is_private = false
    """
  end

  def down do
    # This migration cannot be reversed as we don't know what the correct state should be
  end
end
