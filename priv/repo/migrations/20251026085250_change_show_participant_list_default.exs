defmodule Jamie.Repo.Migrations.ChangeShowParticipantListDefault do
  use Ecto.Migration

  def up do
    alter table(:occurences) do
      modify :show_partecipant_list, :boolean, default: false, null: false
    end
  end

  def down do
    alter table(:occurences) do
      modify :show_partecipant_list, :boolean, default: true, null: false
    end
  end
end
