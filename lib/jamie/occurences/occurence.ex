defmodule Jamie.Occurences.Occurence do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_statuses ~w(scheduled cancelled completed)

  schema "occurences" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :google_place_id, :string
    field :cost, :decimal
    field :photo_url, :string
    field :base_capacity, :integer
    field :flyer_capacity, :integer
    field :subscription_message, :string
    field :cancellation_message, :string
    field :sare_message, :string
    field :disabled, :boolean, default: false
    field :date, :utc_datetime
    field :status, :string, default: "scheduled"
    field :note, :string
    field :slug, :string
    field :show_available_spots, :boolean, default: true
    field :show_partecipant_list, :boolean, default: true
    field :is_private, :boolean, default: false

    belongs_to :created_by, Jamie.Accounts.User
    has_many :coorganizers, Jamie.Occurences.Coorganizer

    timestamps(type: :utc_datetime)
  end

  def changeset(occurence, attrs) do
    # Convert string coordinates to numbers if present
    attrs = normalize_coordinates(attrs)

    occurence
    |> cast(attrs, [
      :title,
      :description,
      :location,
      :latitude,
      :longitude,
      :google_place_id,
      :cost,
      :photo_url,
      :base_capacity,
      :flyer_capacity,
      :subscription_message,
      :cancellation_message,
      :sare_message,
      :disabled,
      :date,
      :status,
      :note,
      :slug,
      :show_available_spots,
      :show_partecipant_list,
      :is_private,
      :created_by_id
    ])
    |> maybe_generate_slug()
    |> validate_required([:title, :date, :slug, :created_by_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_number(:base_capacity, greater_than_or_equal_to: 0)
    |> validate_number(:flyer_capacity, greater_than_or_equal_to: 0)
    |> validate_number(:cost, greater_than_or_equal_to: 0)
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:created_by_id)
  end

  defp normalize_coordinates(attrs) when is_map(attrs) do
    attrs
    |> normalize_coordinate_field("latitude")
    |> normalize_coordinate_field("longitude")
  end

  defp normalize_coordinate_field(attrs, field) do
    case Map.get(attrs, field) do
      value when is_binary(value) and value != "" ->
        case Float.parse(value) do
          {float_value, _} -> Map.put(attrs, field, float_value)
          :error -> attrs
        end

      _ ->
        attrs
    end
  end

  defp maybe_generate_slug(changeset) do
    case get_field(changeset, :slug) do
      nil ->
        title = get_field(changeset, :title)
        date = get_field(changeset, :date)

        if title && date do
          slug = generate_slug(title, date)
          put_change(changeset, :slug, slug)
        else
          changeset
        end

      _slug ->
        changeset
    end
  end

  defp generate_slug(title, date) do
    date_part = Calendar.strftime(date, "%Y%m%d")

    slug_base =
      title
      |> String.downcase()
      |> String.replace(~r/[^\w\s-]/, "")
      |> String.replace(~r/\s+/, "-")

    "#{slug_base}-#{date_part}"
  end
end
