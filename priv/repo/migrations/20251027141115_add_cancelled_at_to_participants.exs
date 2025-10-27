defmodule Jamie.Repo.Migrations.AddCancelledAtToParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :cancelled_at, :utc_datetime
    end
  end
end
