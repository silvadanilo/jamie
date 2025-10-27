defmodule JamieWeb.OccurenceLive.Index do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    upcoming = Occurences.list_upcoming_occurences(user)
    past = Occurences.list_past_occurences(user)

    # Add participant stats to each occurrence
    upcoming_with_stats = Enum.map(upcoming, &add_participant_stats/1)
    past_with_stats = Enum.map(past, &add_participant_stats/1)

    socket =
      socket
      |> assign(:upcoming_occurences, upcoming_with_stats)
      |> assign(:past_occurences, past_with_stats)

    {:ok, socket}
  end

  defp add_participant_stats(occurence) do
    base_confirmed = Occurences.count_confirmed_participants(occurence.id, "base")
    flyer_confirmed = Occurences.count_confirmed_participants(occurence.id, "flyer")

    Map.merge(occurence, %{
      base_registered: base_confirmed,
      flyer_registered: flyer_confirmed
    })
  end

  def handle_event("delete", %{"id" => id}, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      {:ok, _} = Occurences.delete_occurence(occurence)

      socket =
        socket
        |> put_flash(:info, "Event deleted successfully")
        |> assign(:upcoming_occurences, Occurences.list_upcoming_occurences(user))
        |> assign(:past_occurences, Occurences.list_past_occurences(user))

      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "You are not authorized to delete this event")}
    end
  end
end
