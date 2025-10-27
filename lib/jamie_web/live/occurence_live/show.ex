defmodule JamieWeb.OccurenceLive.Show do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(%{"slug" => slug}, _session, socket) do
    occurence = Occurences.get_occurence_by_slug!(slug)
    participants = Occurences.list_participants(occurence.id, "confirmed")

    # Count confirmed participants by role (single query)
    counts = Occurences.count_confirmed_by_role(occurence.id)
    base_count = Map.get(counts, "base", 0)
    flyer_count = Map.get(counts, "flyer", 0)

    # Check if current user is an organizer
    is_organizer =
      if socket.assigns.current_user do
        Occurences.can_manage_occurence?(occurence, socket.assigns.current_user)
      else
        false
      end

    # Check if current user is participating
    user_participation =
      if socket.assigns.current_user do
        Occurences.get_participant(occurence.id, socket.assigns.current_user.id)
      else
        nil
      end

    # Check if event is in the future
    is_future = DateTime.compare(occurence.date, DateTime.utc_now()) == :gt

    {:ok,
     socket
     |> assign(:occurence, occurence)
     |> assign(:participants, participants)
     |> assign(:base_count, base_count)
     |> assign(:flyer_count, flyer_count)
     |> assign(:is_organizer, is_organizer)
     |> assign(:user_participation, user_participation)
     |> assign(:is_future, is_future)}
  end

  def handle_event("unsubscribe", _params, socket) do
    %{occurence: occurence, user_participation: participation} = socket.assigns

    case Occurences.cancel_participant(participation) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "You have successfully unsubscribed from this event")
         |> assign(:user_participation, nil)
         |> push_navigate(to: ~p"/events/#{occurence.slug}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to unsubscribe from this event")}
    end
  end
end
