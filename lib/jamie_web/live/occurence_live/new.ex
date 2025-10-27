defmodule JamieWeb.OccurenceLive.New do
  use JamieWeb, :live_view

  alias Jamie.Occurences
  alias Jamie.Occurences.Occurence
  alias JamieWeb.OccurenceLive.Form

  @impl true
  def mount(_params, _session, socket) do
    # Start with default occurrence
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
     |> assign(:action, :new)
     |> assign(:is_duplicate, false)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    # Check for duplicate ID in params
    {occurence, is_duplicate} =
      case params do
        %{"dup_id" => id} ->
          # Duplicate from existing occurrence
          duplicate_occurence = Occurences.get_occurence!(id)
          duplicate_attrs = Occurences.prepare_duplicate_attrs(duplicate_occurence)

          # Create an occurrence struct from the duplicate attributes
          new_occurence = struct(%Occurence{}, duplicate_attrs)

          {new_occurence, true}

        _ ->
          # Default occurrence
          {socket.assigns.occurence, false}
      end

    changeset = Occurences.change_occurence(occurence)

    {:noreply,
     socket
     |> assign(:occurence, occurence)
     |> assign(:is_duplicate, is_duplicate)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    Form.handle_validate(params, socket)
  end

  @impl true
  def handle_event("save", %{"occurence" => occurence_params}, socket) do
    occurence_params =
      occurence_params
      |> Map.put("created_by_id", socket.assigns.current_user.id)
      |> Form.normalize_for_save()

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
