defmodule JamieWeb.OccurenceLive.Form do
  @moduledoc """
  Shared form logic for creating and editing occurrences.
  """

  alias Jamie.Occurences
  import Phoenix.Component

  def handle_validate(%{"occurence" => occurence_params}, socket) do
    # Automatically set show_partecipant_list to false if is_private is false or not set
    is_private_checked = Map.get(occurence_params, "is_private") == "true"

    # Get the current value from the database/changeset
    current_changeset = Occurences.change_occurence(socket.assigns.occurence)
    was_private = Ecto.Changeset.get_field(current_changeset, :is_private) == true

    occurence_params =
      cond do
        # Transitioning from not-private to private: force show_partecipant_list to false
        is_private_checked and not was_private ->
          Map.put(occurence_params, "show_partecipant_list", "false")

        # Private event is not checked: force show_partecipant_list to false
        not is_private_checked ->
          occurence_params
          |> Map.put("show_partecipant_list", "false")
          |> Map.put("is_private", "false")

        # Was already private: keep show_partecipant_list as user set it
        true ->
          occurence_params
      end

    changeset =
      socket.assigns.occurence
      |> Occurences.change_occurence(occurence_params)
      |> Map.put(:action, :validate)

    socket
    |> assign(:form, to_form(changeset))
    |> then(&{:noreply, &1})
  end

  def normalize_for_save(occurence_params) do
    # Ensure show_partecipant_list is false if is_private is false
    is_private_checked = Map.get(occurence_params, "is_private") == "true"

    if not is_private_checked do
      Map.put(occurence_params, "show_partecipant_list", "false")
    else
      occurence_params
    end
  end
end
