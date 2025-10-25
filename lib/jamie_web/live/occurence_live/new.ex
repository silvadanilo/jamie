defmodule JamieWeb.OccurenceLive.New do
  use JamieWeb, :live_view

  alias Jamie.Occurences.Occurence

  def mount(_params, _session, socket) do
    occurence = %Occurence{
      show_available_spots: true,
      show_partecipant_list: true,
      is_private: false,
      disabled: false,
      status: "scheduled"
    }

    {:ok, assign(socket, :occurence, occurence)}
  end

  def handle_info({JamieWeb.OccurenceLive.FormComponent, {:saved, _occurence}}, socket) do
    {:noreply, socket}
  end
end
