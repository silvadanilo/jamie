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

    belongs_to :occurence, Jamie.Occurences.Occurence
    belongs_to :user, Jamie.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:status, :role, :notes, :nickname, :occurence_id, :user_id])
    |> validate_required([:occurence_id, :user_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_inclusion(:role, @valid_roles)
    |> unique_constraint([:occurence_id, :user_id],
      message: "User is already registered for this event"
    )
  end

  def role_changeset(participant, attrs) do
    participant
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, @valid_roles)
  end
end
