defmodule Jamie.Repo.Migrations.AddShowParticipantListCheckConstraint do
  use Ecto.Migration

  def up do
    create constraint(:occurences, :show_participant_list_only_for_private,
             check: "NOT (show_partecipant_list = true AND is_private = false)"
           )
  end

  def down do
    drop constraint(:occurences, :show_participant_list_only_for_private)
  end
end
