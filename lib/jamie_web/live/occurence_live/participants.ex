defmodule JamieWeb.OccurenceLive.Participants do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(%{"id" => id}, _session, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      confirmed = Occurences.list_participants(occurence.id, "confirmed")
      waitlist = Occurences.list_participants(occurence.id, "waitlist")
      cancelled = Occurences.list_participants(occurence.id, "cancelled")

      # Calculate statistics
      base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
      flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
      base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
      flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

      total_participants = length(confirmed)
      total_waitlist = length(waitlist)

      base_available = (occurence.base_capacity || 0) - base_confirmed
      flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

      socket =
        socket
        |> assign(:occurence, occurence)
        |> assign(:confirmed_participants, confirmed)
        |> assign(:waitlist_participants, waitlist)
        |> assign(:cancelled_participants, cancelled)
        |> assign(:base_confirmed, base_confirmed)
        |> assign(:flyer_confirmed, flyer_confirmed)
        |> assign(:base_waitlist, base_waitlist)
        |> assign(:flyer_waitlist, flyer_waitlist)
        |> assign(:total_participants, total_participants)
        |> assign(:total_waitlist, total_waitlist)
        |> assign(:base_available, base_available)
        |> assign(:flyer_available, flyer_available)
        |> assign(:editing_capacity, nil)

      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to view participants for this event")
        |> push_navigate(to: ~p"/occurences")

      {:ok, socket}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    {:ok, _} = Occurences.cancel_participant(participant)

    # Recalculate statistics
    confirmed = Occurences.list_participants(occurence.id, "confirmed")
    waitlist = Occurences.list_participants(occurence.id, "waitlist")
    cancelled = Occurences.list_participants(occurence.id, "cancelled")

    base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
    flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
    base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
    flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

    total_participants = length(confirmed)
    total_waitlist = length(waitlist)

    base_available = (occurence.base_capacity || 0) - base_confirmed
    flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

    socket =
      socket
      |> put_flash(:info, "Participant cancelled successfully")
      |> assign(:confirmed_participants, confirmed)
      |> assign(:waitlist_participants, waitlist)
      |> assign(:cancelled_participants, cancelled)
      |> assign(:base_confirmed, base_confirmed)
      |> assign(:flyer_confirmed, flyer_confirmed)
      |> assign(:base_waitlist, base_waitlist)
      |> assign(:flyer_waitlist, flyer_waitlist)
      |> assign(:total_participants, total_participants)
      |> assign(:total_waitlist, total_waitlist)
      |> assign(:base_available, base_available)
      |> assign(:flyer_available, flyer_available)

    {:noreply, socket}
  end

  def handle_event("promote_from_waitlist", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    {:ok, _} = Occurences.promote_participant_to_confirmed(participant)

    # Recalculate statistics
    confirmed = Occurences.list_participants(occurence.id, "confirmed")
    waitlist = Occurences.list_participants(occurence.id, "waitlist")

    base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
    flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
    base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
    flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

    total_participants = length(confirmed)
    total_waitlist = length(waitlist)

    base_available = (occurence.base_capacity || 0) - base_confirmed
    flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

    socket =
      socket
      |> put_flash(:info, "Participant promoted to confirmed")
      |> assign(:confirmed_participants, confirmed)
      |> assign(:waitlist_participants, waitlist)
      |> assign(:base_confirmed, base_confirmed)
      |> assign(:flyer_confirmed, flyer_confirmed)
      |> assign(:base_waitlist, base_waitlist)
      |> assign(:flyer_waitlist, flyer_waitlist)
      |> assign(:total_participants, total_participants)
      |> assign(:total_waitlist, total_waitlist)
      |> assign(:base_available, base_available)
      |> assign(:flyer_available, flyer_available)

    {:noreply, socket}
  end

  def handle_event("promote_from_cancelled", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    case Occurences.restore_participant(participant, occurence) do
      {:ok, _participant} ->
        # Recalculate statistics
        confirmed = Occurences.list_participants(occurence.id, "confirmed")
        waitlist = Occurences.list_participants(occurence.id, "waitlist")
        cancelled = Occurences.list_participants(occurence.id, "cancelled")

        base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
        flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
        base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
        flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

        total_participants = length(confirmed)
        total_waitlist = length(waitlist)

        base_available = (occurence.base_capacity || 0) - base_confirmed
        flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

        socket =
          socket
          |> put_flash(:info, "Participant restored successfully")
          |> assign(:confirmed_participants, confirmed)
          |> assign(:waitlist_participants, waitlist)
          |> assign(:cancelled_participants, cancelled)
          |> assign(:base_confirmed, base_confirmed)
          |> assign(:flyer_confirmed, flyer_confirmed)
          |> assign(:base_waitlist, base_waitlist)
          |> assign(:flyer_waitlist, flyer_waitlist)
          |> assign(:total_participants, total_participants)
          |> assign(:total_waitlist, total_waitlist)
          |> assign(:base_available, base_available)
          |> assign(:flyer_available, flyer_available)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to restore participant")}
    end
  end

  def handle_event("start_edit_capacity", %{"type" => type}, socket) do
    {:noreply, assign(socket, :editing_capacity, type)}
  end

  def handle_event("cancel_edit_capacity", _params, socket) do
    {:noreply, assign(socket, :editing_capacity, nil)}
  end

  def handle_event("update_capacity", %{"type" => type, "capacity" => capacity}, socket) do
    occurence = socket.assigns.occurence
    capacity_int = String.to_integer(capacity)

    attrs =
      case type do
        "base" -> %{base_capacity: capacity_int}
        "flyer" -> %{flyer_capacity: capacity_int}
      end

    case Occurences.update_occurence(occurence, attrs) do
      {:ok, updated_occurence} ->
        # Recalculate statistics
        confirmed = Occurences.list_participants(updated_occurence.id, "confirmed")
        waitlist = Occurences.list_participants(updated_occurence.id, "waitlist")

        base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
        flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
        base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
        flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

        total_participants = length(confirmed)
        total_waitlist = length(waitlist)

        base_available = (updated_occurence.base_capacity || 0) - base_confirmed
        flyer_available = (updated_occurence.flyer_capacity || 0) - flyer_confirmed

        socket =
          socket
          |> put_flash(:info, "Capacity updated successfully")
          |> assign(:occurence, updated_occurence)
          |> assign(:base_confirmed, base_confirmed)
          |> assign(:flyer_confirmed, flyer_confirmed)
          |> assign(:base_waitlist, base_waitlist)
          |> assign(:flyer_waitlist, flyer_waitlist)
          |> assign(:total_participants, total_participants)
          |> assign(:total_waitlist, total_waitlist)
          |> assign(:base_available, base_available)
          |> assign(:flyer_available, flyer_available)
          |> assign(:editing_capacity, nil)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update capacity")}
    end
  end
end
