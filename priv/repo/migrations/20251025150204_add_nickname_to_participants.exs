defmodule Jamie.Repo.Migrations.AddNicknameToParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :nickname, :string
    end
  end
end
