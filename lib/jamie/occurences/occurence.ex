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
    field :share_message, :string
    field :disabled, :boolean, default: false
    field :date, :utc_datetime
    field :status, :string, default: "scheduled"
    field :note, :string
    field :slug, :string
    field :show_available_spots, :boolean, default: true
    field :show_partecipant_list, :boolean, default: false
    field :is_private, :boolean, default: false

    belongs_to :created_by, Jamie.Accounts.User
    has_many :coorganizers, Jamie.Occurences.Coorganizer
    has_many :participants, Jamie.Occurences.Participant

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
      :share_message,
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
    |> maybe_set_default_messages()
    |> validate_required([:title, :date, :slug, :created_by_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_number(:base_capacity, greater_than_or_equal_to: 0)
    |> validate_number(:flyer_capacity, greater_than_or_equal_to: 0)
    |> validate_number(:cost, greater_than_or_equal_to: 0)
    |> validate_show_participant_list_constraint()
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:created_by_id)
  end

  defp validate_show_participant_list_constraint(changeset) do
    is_private = get_field(changeset, :is_private)
    show_participant_list = get_field(changeset, :show_partecipant_list)

    if show_participant_list == true && is_private != true do
      add_error(changeset, :show_partecipant_list, "Participant list can only be shown for private events")
    else
      changeset
    end
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
        slug = Ecto.UUID.generate()
        put_change(changeset, :slug, slug)

      _slug ->
        changeset
    end
  end

  defp maybe_set_default_messages(changeset) do
    changeset
    |> maybe_set_default_subscription_message()
    |> maybe_set_default_cancellation_message()
    |> maybe_set_default_share_message()
  end

  defp maybe_set_default_subscription_message(changeset) do
    subscription_message = get_field(changeset, :subscription_message)

    if is_nil(subscription_message) or subscription_message == "" do
      put_change(changeset, :subscription_message, default_subscription_message())
    else
      changeset
    end
  end

  defp maybe_set_default_cancellation_message(changeset) do
    cancellation_message = get_field(changeset, :cancellation_message)

    if is_nil(cancellation_message) or cancellation_message == "" do
      put_change(changeset, :cancellation_message, default_cancellation_message())
    else
      changeset
    end
  end

  defp maybe_set_default_share_message(changeset) do
    share_message = get_field(changeset, :share_message)

    if is_nil(share_message) or share_message == "" do
      put_change(changeset, :share_message, default_share_message())
    else
      changeset
    end
  end

  defp default_subscription_message do
    """
    Bentornato/a alla {title}!

    Ti confermo la tua prenotazione per il {date}.

    📍 Luogo: {location}
    🕐 Orario: {time}
    💰 Contributo sala: {cost}€

    Se hai domande o cambiamenti, scrivimi pure.

    A presto!
    """
  end

  defp default_cancellation_message do
    """
    La tua prenotazione per la {title} del {date} è stata cancellata.

    Se desideri prenotare per un'altra sessione, fammi sapere!

    A presto!
    """
  end

  defp default_share_message do
    """
    Prenotazioni per la {title}!
    📍 Dove: {location}
    🕐 Quando: {datetime}
    ❓ Per chi: adatto a chiunque abbia voglia di praticare divertendosi e condividere momenti.
    💰 Contributo sala: {cost}€ (contanti o Satispay)

    📩 Per ulteriori info e prenotazioni scrivetemi in privato 😊
    """
  end
end
