defmodule Jamie.Occurences do
  @moduledoc """
  The Occurences context.
  """

  import Ecto.Query, warn: false
  alias Jamie.Repo

  alias Jamie.Occurences.Occurence
  alias Jamie.Occurences.Coorganizer
  alias Jamie.Occurences.Participant
  alias Jamie.Accounts.User

  @doc """
  Returns the list of occurences for a given user.
  """
  def list_occurences(user) do
    Occurence
    |> where([o], o.created_by_id == ^user.id)
    |> order_by([o], desc: o.date)
    |> Repo.all()
  end

  @doc """
  Returns the list of all occurences (for superadmin).
  """
  def list_all_occurences do
    Occurence
    |> order_by([o], desc: o.date)
    |> Repo.all()
  end

  @doc """
  Returns the list of upcoming public occurences.
  Sorted from nearest to farthest.
  """
  def list_public_occurences do
    now = DateTime.utc_now()

    Occurence
    |> where([o], o.is_private == false and o.disabled == false)
    |> where([o], o.date >= ^now)
    |> order_by([o], asc: o.date)
    |> Repo.all()
  end

  @doc """
  Gets a single occurence.

  Raises `Ecto.NoResultsError` if the Occurence does not exist.
  """
  def get_occurence!(id), do: Repo.get!(Occurence, id)

  @doc """
  Gets a single occurence by slug.

  Raises `Ecto.NoResultsError` if the Occurence does not exist.
  """
  def get_occurence_by_slug!(slug) do
    Repo.get_by!(Occurence, slug: slug)
  end

  @doc """
  Creates a occurence and automatically adds the creator as a coorganizer.
  """
  def create_occurence(attrs \\ %{}) do
    Repo.transaction(fn ->
      with {:ok, occurence} <- store_occurence(attrs),
           {:ok, _coorganizer} <- store_creator_as_coorganizer(occurence) do
        occurence
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  defp store_occurence(attrs) do
    %Occurence{} |> Occurence.changeset(attrs) |> Repo.insert()
  end

  defp store_creator_as_coorganizer(occurence) do
    %Coorganizer{}
    |> Coorganizer.changeset(%{
      occurence_id: occurence.id,
      user_id: occurence.created_by_id,
      accepted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      is_creator: true
    })
    |> Repo.insert()
  end

  @doc """
  Updates a occurence.
  """
  def update_occurence(%Occurence{} = occurence, attrs) do
    occurence
    |> Occurence.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a occurence.
  """
  def delete_occurence(%Occurence{} = occurence) do
    Repo.delete(occurence)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking occurence changes.
  """
  def change_occurence(%Occurence{} = occurence, attrs \\ %{}) do
    Occurence.changeset(occurence, attrs)
  end

  @doc """
  Updates the status of an occurence.
  """
  def update_occurence_status(%Occurence{} = occurence, status)
      when status in ["scheduled", "cancelled", "completed"] do
    update_occurence(occurence, %{status: status})
  end

  @doc """
  Toggles the disabled state of an occurence.
  """
  def toggle_occurence_disabled(%Occurence{} = occurence) do
    update_occurence(occurence, %{disabled: !occurence.disabled})
  end

  @doc """
  Returns upcoming occurences for a user (where they're the creator or a coorganizer).
  Sorted from nearest to farthest.
  """
  def list_upcoming_occurences(user) do
    now = DateTime.utc_now()

    from(o in Occurence,
      join: c in Coorganizer,
      on: c.occurence_id == o.id,
      where: c.user_id == ^user.id,
      where: not is_nil(c.accepted_at),
      where: o.date >= ^now,
      order_by: [asc: o.date]
    )
    |> Repo.all()
  end

  @doc """
  Returns past occurences for a user (where they're the creator or a coorganizer).
  Sorted from most recent to oldest.
  """
  def list_past_occurences(user) do
    now = DateTime.utc_now()

    from(o in Occurence,
      join: c in Coorganizer,
      on: c.occurence_id == o.id,
      where: c.user_id == ^user.id,
      where: not is_nil(c.accepted_at),
      where: o.date < ^now,
      order_by: [desc: o.date]
    )
    |> Repo.all()
  end

  @doc """
  Invites a co-organizer by email.
  """
  def invite_coorganizer(occurence_id, invited_email, invited_by_user) do
    occurence = get_occurence!(occurence_id)

    case Repo.get_by(User, email: invited_email) do
      nil ->
        create_pending_invitation(occurence, invited_email, invited_by_user)

      existing_user ->
        create_accepted_invitation(occurence, existing_user, invited_by_user)
    end
  end

  defp create_pending_invitation(occurence, invited_email, invited_by_user) do
    attrs = %{
      occurence_id: occurence.id,
      invited_email: invited_email,
      invited_by_id: invited_by_user.id
    }

    result =
      %Coorganizer{}
      |> Coorganizer.invite_changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, coorganizer} ->
        token_url = build_invitation_url(coorganizer.invite_token)

        Jamie.Occurences.Notifier.deliver_coorganizer_invitation_new_user(
          coorganizer,
          occurence,
          invited_by_user,
          token_url
        )

        {:ok, coorganizer}

      error ->
        error
    end
  end

  defp create_accepted_invitation(occurence, existing_user, invited_by_user) do
    attrs = %{
      occurence_id: occurence.id,
      invited_email: existing_user.email,
      user_id: existing_user.id,
      invited_by_id: invited_by_user.id,
      accepted_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    result =
      %Coorganizer{}
      |> Coorganizer.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, coorganizer} ->
        Jamie.Occurences.Notifier.deliver_coorganizer_invitation_existing_user(
          coorganizer,
          occurence,
          invited_by_user
        )

        {:ok, coorganizer}

      error ->
        error
    end
  end

  defp build_invitation_url(token) do
    JamieWeb.Endpoint.url() <> "/coorganizer-invite/#{token}"
  end

  @doc """
  Gets a coorganizer invitation by token.
  """
  def get_coorganizer_by_token(token) do
    Repo.get_by(Coorganizer, invite_token: token)
  end

  @doc """
  Accepts a co-organizer invitation.
  """
  def accept_coorganizer_invitation(%Coorganizer{} = coorganizer, user_id) do
    if Coorganizer.token_valid?(coorganizer) do
      coorganizer
      |> Coorganizer.accept_changeset(user_id)
      |> Repo.update()
    else
      {:error, :token_expired}
    end
  end

  @doc """
  Lists all co-organizers for an occurence.
  """
  def list_coorganizers(occurence_id) do
    Coorganizer
    |> where([c], c.occurence_id == ^occurence_id)
    |> preload([:user, :invited_by])
    |> Repo.all()
  end

  @doc """
  Removes a co-organizer.
  """
  def remove_coorganizer(%Coorganizer{} = coorganizer) do
    Repo.delete(coorganizer)
  end

  @doc """
  Checks if the user can manage the occurence (is creator, co-organizer, or superadmin).
  """
  def can_manage_occurence?(%Occurence{} = occurence, user) do
    user.role == "superadmin" or is_coorganizer?(occurence.id, user.id)
  end

  @doc """
  Checks if a user is a co-organizer of an occurence (including creator).
  """
  def is_coorganizer?(occurence_id, user_id) do
    Coorganizer
    |> where([c], c.occurence_id == ^occurence_id)
    |> where([c], c.user_id == ^user_id)
    |> where([c], not is_nil(c.accepted_at))
    |> Repo.exists?()
  end

  @doc """
  Checks if a user is the creator of an occurence.
  """
  def is_creator?(occurence_id, user_id) do
    Coorganizer
    |> where([c], c.occurence_id == ^occurence_id)
    |> where([c], c.user_id == ^user_id)
    |> where([c], c.is_creator == true)
    |> Repo.exists?()
  end

  ## Participants

  @doc """
  Checks if a user is already registered for an event.
  """
  def user_registered?(occurence_id, user_id) do
    Participant
    |> where([p], p.occurence_id == ^occurence_id)
    |> where([p], p.user_id == ^user_id)
    |> Repo.exists?()
  end

  @doc """
  Gets a participant by occurence and user.
  """
  def get_participant(occurence_id, user_id) do
    Participant
    |> where([p], p.occurence_id == ^occurence_id)
    |> where([p], p.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Counts confirmed participants for an event by registration type.
  """
  def count_confirmed_participants(occurence_id, role \\ "base") do
    Participant
    |> where([p], p.occurence_id == ^occurence_id)
    |> where([p], p.role == ^role)
    |> where([p], p.status == "confirmed")
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns confirmed participant counts grouped by role in a single query.
  Returns a map like %{"base" => 3, "flyer" => 2}
  """
  def count_confirmed_by_role(occurence_id) do
    Participant
    |> where([p], p.occurence_id == ^occurence_id)
    |> where([p], p.status == "confirmed")
    |> group_by([p], p.role)
    |> select([p], {p.role, count(p.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Checks if an event has available spots.
  Returns {:ok, role} if spots available, {:error, :full} if full.
  If capacity is nil, it's considered unlimited.
  """
  def check_available_spots(occurence) do
    base_count = count_confirmed_participants(occurence.id, "base")
    flyer_count = count_confirmed_participants(occurence.id, "flyer")

    cond do
      # If base_capacity is nil, it's unlimited
      is_nil(occurence.base_capacity) -> {:ok, "base"}
      # If base has available spots
      base_count < occurence.base_capacity -> {:ok, "base"}
      # If flyer_capacity is nil, it's unlimited
      is_nil(occurence.flyer_capacity) -> {:ok, "flyer"}
      # If flyer has available spots
      flyer_count < occurence.flyer_capacity -> {:ok, "flyer"}
      # Both are full
      true -> {:error, :full}
    end
  end

  @doc """
  Registers a user for an event.
  """
  def register_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all participants for an event with user preloaded.
  Optionally filters by status if provided.
  """
  def list_participants(occurence_id, status \\ nil) do
    query =
      Participant
      |> where([p], p.occurence_id == ^occurence_id)
      |> order_by([p], asc: p.inserted_at)

    query =
      if status do
        where(query, [p], p.status == ^status)
      else
        query
      end

    query
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Cancels a participant registration.
  """
  def cancel_participant(participant) do
    participant
    |> Participant.changeset(%{status: "cancelled"})
    |> Repo.update()
  end

  @doc """
  Gets a single participant by ID.
  """
  def get_participant_by_id!(id) do
    Participant
    |> preload(:user)
    |> Repo.get!(id)
  end

  @doc """
  Deletes a participant.
  """
  def delete_participant(participant) do
    Repo.delete(participant)
  end

  @doc """
  Promotes a participant from waitlist to confirmed.
  """
  def promote_participant_to_confirmed(participant) do
    participant
    |> Participant.changeset(%{status: "confirmed"})
    |> Repo.update()
  end

  @doc """
  Restores a participant from cancelled status.
  Checks if there are available spots and assigns to confirmed or waitlist accordingly.
  """
  def restore_participant(participant, occurence) do
    case check_available_spots(occurence) do
      {:ok, _role} ->
        participant
        |> Participant.changeset(%{status: "confirmed"})
        |> Repo.update()

      {:error, :full} ->
        participant
        |> Participant.changeset(%{status: "waitlist"})
        |> Repo.update()
    end
  end

  @doc """
  Creates or gets a user for a participant.
  """
  def create_or_get_user_for_participant(attrs) do
    # Try to find existing user by email first
    case attrs["email"] do
      nil ->
        # If no email provided, create a new user
        create_user_for_participant(attrs)

      email ->
        case Repo.get_by(User, email: email) do
          nil ->
            # User doesn't exist, create new one
            create_user_for_participant(attrs)

          user ->
            # User exists, update with new info if provided
            user
            |> User.profile_changeset(attrs)
            |> Repo.update()
        end
    end
  end

  defp create_user_for_participant(attrs) do
    # Generate a unique email if not provided
    email =
      attrs["email"] || "#{attrs["name"]}.#{attrs["surname"]}.#{System.unique_integer([:positive])}@participant.local"

    user_attrs = Map.put(attrs, "email", email)

    %User{}
    |> User.registration_changeset(user_attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a changeset for a participant.
  """
  def change_participant(%Participant{} = participant, attrs \\ %{}) do
    Participant.changeset(participant, attrs)
  end

  @doc """
  Creates a participant.
  """
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a participant's role.
  """
  def update_participant_role(participant, role) do
    participant
    |> Participant.role_changeset(%{role: role})
    |> Repo.update()
  end
end
