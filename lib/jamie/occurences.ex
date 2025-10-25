defmodule Jamie.Occurences do
  @moduledoc """
  The Occurences context.
  """

  import Ecto.Query, warn: false
  alias Jamie.Repo

  alias Jamie.Occurences.Occurence
  alias Jamie.Occurences.Coorganizer
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
  Returns the list of public occurences.
  """
  def list_public_occurences do
    Occurence
    |> where([o], o.is_private == false and o.disabled == false)
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
    creator_email = get_creator_email(occurence.created_by_id)

    %Coorganizer{}
    |> Coorganizer.changeset(%{
      occurence_id: occurence.id,
      user_id: occurence.created_by_id,
      accepted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      is_creator: true
    })
    |> Repo.insert()
  end

  defp get_creator_email(user_id) do
    user = Repo.get!(User, user_id)
    user.email
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
end
