defmodule Jamie.Occurences.Coorganizer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "occurence_coorganizers" do
    field :invited_email, :string
    field :invite_token, :string
    field :invite_token_expires_at, :utc_datetime
    field :accepted_at, :utc_datetime
    field :is_creator, :boolean, default: false

    belongs_to :occurence, Jamie.Occurences.Occurence
    belongs_to :user, Jamie.Accounts.User
    belongs_to :invited_by, Jamie.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(coorganizer, attrs) do
    coorganizer
    |> cast(attrs, [
      :invited_email,
      :invite_token,
      :invite_token_expires_at,
      :accepted_at,
      :occurence_id,
      :user_id,
      :invited_by_id,
      :is_creator
    ])
    |> validate_required([:occurence_id])
    |> validate_required_unless_creator()
    |> validate_email_format()
    |> foreign_key_constraint(:occurence_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:invited_by_id)
  end

  defp validate_email_format(changeset) do
    case get_field(changeset, :invited_email) do
      nil ->
        changeset

      _email ->
        validate_format(changeset, :invited_email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    end
  end

  defp validate_required_unless_creator(changeset) do
    is_creator = get_field(changeset, :is_creator, false)

    if is_creator do
      changeset
    else
      validate_required(changeset, [:invited_by_id, :invited_email])
    end
  end

  def invite_changeset(coorganizer, attrs) do
    coorganizer
    |> changeset(attrs)
    |> put_invite_token()
  end

  defp put_invite_token(changeset) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    expires_at = DateTime.utc_now() |> DateTime.add(48, :hour) |> DateTime.truncate(:second)

    changeset
    |> put_change(:invite_token, token)
    |> put_change(:invite_token_expires_at, expires_at)
  end

  def accept_changeset(coorganizer, user_id) do
    accepted_at = DateTime.utc_now() |> DateTime.truncate(:second)

    coorganizer
    |> change()
    |> put_change(:user_id, user_id)
    |> put_change(:accepted_at, accepted_at)
    |> put_change(:invite_token, nil)
    |> put_change(:invite_token_expires_at, nil)
  end

  def token_valid?(%__MODULE__{invite_token_expires_at: nil}), do: false

  def token_valid?(%__MODULE__{invite_token_expires_at: expires_at}) do
    DateTime.compare(DateTime.utc_now(), expires_at) == :lt
  end
end
