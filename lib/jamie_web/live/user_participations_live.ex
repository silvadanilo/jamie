defmodule JamieWeb.UserParticipationsLive do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    upcoming_records = Occurences.list_upcoming_user_participations_with_records(user.id)
    past = Occurences.list_past_user_participations(user.id)

    {:ok,
     socket
     |> assign(:upcoming_participations, upcoming_records)
     |> assign(:past_participations, past)}
  end

  def handle_event("unsubscribe", %{"participation_id" => participation_id}, socket) do
    participation = Occurences.get_participant_by_id!(participation_id)

    case Occurences.cancel_participant(participation) do
      {:ok, _} ->
        # Refresh the list
        upcoming_records = Occurences.list_upcoming_user_participations_with_records(socket.assigns.current_user.id)

        {:noreply,
         socket
         |> put_flash(:info, "You have successfully unsubscribed from this event")
         |> assign(:upcoming_participations, upcoming_records)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to unsubscribe from this event")}
    end
  end
end
