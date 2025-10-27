defmodule Jamie.Repo.Migrations.AddRegisteredAtToParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :registered_at, :utc_datetime
    end
  end
end
