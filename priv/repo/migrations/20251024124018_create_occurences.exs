defmodule Jamie.Repo.Migrations.CreateOccurences do
  use Ecto.Migration

  def change do
    create table(:occurences, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :location, :string
      add :latitude, :decimal, precision: 10, scale: 8
      add :longitude, :decimal, precision: 11, scale: 8
      add :google_place_id, :string
      add :cost, :decimal, precision: 10, scale: 2
      add :photo_url, :string
      add :base_capacity, :integer
      add :flyer_capacity, :integer
      add :subscription_message, :text
      add :cancellation_message, :text
      add :sare_message, :text
      add :disabled, :boolean, default: false, null: false
      add :date, :utc_datetime, null: false
      add :status, :string, default: "scheduled", null: false
      add :note, :text
      add :slug, :string, null: false
      add :show_available_spots, :boolean, default: true, null: false
      add :show_partecipant_list, :boolean, default: true, null: false
      add :is_private, :boolean, default: false, null: false

      add :created_by_id, references(:users, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:occurences, [:created_by_id])
    create index(:occurences, [:date])
    create index(:occurences, [:status])
    create unique_index(:occurences, [:slug])
  end
end
