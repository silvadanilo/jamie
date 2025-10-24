defmodule Jamie.Occurences do
  @moduledoc """
  The Occurences context.
  """

  import Ecto.Query, warn: false
  alias Jamie.Repo

  alias Jamie.Occurences.Occurence

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
  Creates a occurence.
  """
  def create_occurence(attrs \\ %{}) do
    %Occurence{}
    |> Occurence.changeset(attrs)
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
  Checks if the user can manage the occurence (is creator or superadmin).
  """
  def can_manage_occurence?(%Occurence{} = occurence, user) do
    user.role == "superadmin" or occurence.created_by_id == user.id
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
  Returns upcoming occurences for a user.
  """
  def list_upcoming_occurences(user) do
    now = DateTime.utc_now()

    Occurence
    |> where([o], o.created_by_id == ^user.id)
    |> where([o], o.date >= ^now)
    |> where([o], o.status == "scheduled")
    |> where([o], o.disabled == false)
    |> order_by([o], asc: o.date)
    |> Repo.all()
  end

  @doc """
  Returns past occurences for a user.
  """
  def list_past_occurences(user) do
    now = DateTime.utc_now()

    Occurence
    |> where([o], o.created_by_id == ^user.id)
    |> where([o], o.date < ^now or o.status in ["cancelled", "completed"])
    |> order_by([o], desc: o.date)
    |> Repo.all()
  end
end
