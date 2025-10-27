defmodule Jamie.Repo.Migrations.EnablePgcrypto do
  use Ecto.Migration

  def up do
    # Enable pgcrypto extension for UUID generation functions
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"
  end

  def down do
    execute "DROP EXTENSION IF EXISTS pgcrypto"
  end
end

