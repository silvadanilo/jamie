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

    {:ok,
     socket
     |> assign(:occurence, occurence)
     |> assign(:participants, participants)
     |> assign(:base_count, base_count)
     |> assign(:flyer_count, flyer_count)}
  end
end
