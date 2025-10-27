defmodule Jamie.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up do
    # Enable pgcrypto extension for UUID generation functions
    # This is needed for gen_random_uuid() in later migrations
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    Oban.Migration.up(version: 12)
  end

  def down do
    Oban.Migration.down(version: 1)
    execute "DROP EXTENSION IF EXISTS pgcrypto"
  end
end
