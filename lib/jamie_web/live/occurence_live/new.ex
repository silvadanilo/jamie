defmodule JamieWeb.OccurenceLive.New do
  use JamieWeb, :live_view

  alias Jamie.Occurences
  alias Jamie.Occurences.Occurence

  def mount(_params, _session, socket) do
    occurence = %Occurence{
      show_available_spots: true,
      show_partecipant_list: false,
      is_private: false,
      disabled: false,
      status: "scheduled"
    }

    changeset = Occurences.change_occurence(occurence)

    {:ok,
     socket
     |> assign(:occurence, occurence)
     |> assign(:page_title, "Create New Event")
     |> assign_form(changeset)}
  end

  def handle_event("validate", %{"occurence" => occurence_params}, socket) do
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

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"occurence" => occurence_params}, socket) do
    occurence_params = Map.put(occurence_params, "created_by_id", socket.assigns.current_user.id)

    # Ensure show_partecipant_list is false if is_private is false
    is_private_checked = Map.get(occurence_params, "is_private") == "true"

    occurence_params =
      if not is_private_checked do
        Map.put(occurence_params, "show_partecipant_list", "false")
      else
        occurence_params
      end

    case Occurences.create_occurence(occurence_params) do
      {:ok, _occurence} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_navigate(to: ~p"/organizer/occurences")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
