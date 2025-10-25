defmodule Jamie.Repo.Migrations.AllowNullInvitedEmailForCreators do
  use Ecto.Migration

  def change do
    alter table(:occurence_coorganizers) do
      modify :invited_email, :string, null: true, from: {:string, null: false}
    end
  end
end
