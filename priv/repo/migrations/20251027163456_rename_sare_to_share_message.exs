defmodule Jamie.Repo.Migrations.RenameSareToShareMessage do
  use Ecto.Migration

  def change do
    rename table(:occurences), :sare_message, to: :share_message
  end
end
