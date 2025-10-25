defmodule JamieWeb.OccurenceLive.Index do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    upcoming = Occurences.list_upcoming_occurences(user)
    past = Occurences.list_past_occurences(user)

    socket =
      socket
      |> assign(:upcoming_occurences, upcoming)
      |> assign(:past_occurences, past)

    {:ok, socket}
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
