defmodule Jamie.Repo.Migrations.AddRegistrationFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :nickname, :string
    end
  end
end
