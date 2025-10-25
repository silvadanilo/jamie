defmodule Jamie.Occurences.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_statuses ~w(confirmed waitlist cancelled)
  @valid_roles ~w(base flyer)

  schema "participants" do
    field :status, :string, default: "confirmed"
    field :role, :string, default: "base"
    field :notes, :string
    field :nickname, :string
    field :name, :string
    field :surname, :string
    field :phone, :string
    field :email, :string

    belongs_to :occurence, Jamie.Occurences.Occurence
    belongs_to :user, Jamie.Accounts.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:status, :role, :notes, :nickname, :name, :surname, :phone, :email, :occurence_id, :user_id])
    |> validate_required([:occurence_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_inclusion(:role, @valid_roles)
    |> validate_email_or_phone()
    |> validate_user_or_contact_info()
    |> unique_constraint([:occurence_id, :user_id],
      message: "User is already registered for this event"
    )
    |> unique_constraint([:occurence_id, :email],
      message: "Email is already registered for this event"
    )
  end

  defp validate_email_or_phone(changeset) do
    email = get_field(changeset, :email)
    phone = get_field(changeset, :phone)
    user_id = get_field(changeset, :user_id)

    if user_id do
      changeset
    else
      if is_nil(email) and is_nil(phone) do
        add_error(changeset, :email, "Either email or phone must be provided")
      else
        changeset
      end
    end
  end

  defp validate_user_or_contact_info(changeset) do
    user_id = get_field(changeset, :user_id)
    name = get_field(changeset, :name)

    cond do
      user_id && is_nil(name) ->
        # User ID provided, no name required
        changeset

      is_nil(user_id) && name ->
        # No user ID, name is required
        changeset

      is_nil(user_id) && is_nil(name) ->
        # Neither provided, error
        add_error(changeset, :name, "Either user_id or name must be provided")

      user_id && name ->
        # Both provided, that's fine too
        changeset
    end
  end

  def role_changeset(participant, attrs) do
    participant
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, @valid_roles)
  end
end
