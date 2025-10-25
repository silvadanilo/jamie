defmodule JamieWeb.OccurenceLive.Edit do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(%{"id" => id}, _session, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      {:ok, assign(socket, :occurence, occurence)}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to edit this event")
        |> push_navigate(to: ~p"/occurences")

      {:ok, socket}
    end
  end

  def handle_info({JamieWeb.OccurenceLive.FormComponent, {:saved, _occurence}}, socket) do
    {:noreply, socket}
  end
end
