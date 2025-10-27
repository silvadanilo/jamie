defmodule Jamie.Repo.Migrations.PopulateCreatorsAsCoorganizers do
  use Ecto.Migration

  def up do
    # Enable pgcrypto extension for UUID generation
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    # Add all existing occurence creators as coorganizers with is_creator = true
    execute """
    INSERT INTO occurence_coorganizers (
      id,
      occurence_id,
      user_id,
      invited_email,
      invited_by_id,
      accepted_at,
      is_creator,
      inserted_at,
      updated_at
    )
    SELECT
      gen_random_uuid(),
      o.id,
      o.created_by_id,
      u.email,
      o.created_by_id,
      o.inserted_at,
      true,
      NOW(),
      NOW()
    FROM occurences o
    JOIN users u ON u.id = o.created_by_id
    WHERE NOT EXISTS (
      SELECT 1 FROM occurence_coorganizers c
      WHERE c.occurence_id = o.id
      AND c.user_id = o.created_by_id
      AND c.is_creator = true
    )
    """
  end

  def down do
    # Remove all creator coorganizer entries
    execute """
    DELETE FROM occurence_coorganizers
    WHERE is_creator = true
    """
  end
end
