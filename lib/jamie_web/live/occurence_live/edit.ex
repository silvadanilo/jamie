defmodule JamieWeb.OccurenceLive.Edit do
  use JamieWeb, :live_view

  alias Jamie.Occurences
  alias JamieWeb.OccurenceLive.Form

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      changeset = Occurences.change_occurence(occurence)

      {:ok,
       socket
       |> assign(:occurence, occurence)
       |> assign(:page_title, "Edit Event")
       |> assign(:action, :edit)
       |> assign_form(changeset)}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to edit this event")
        |> push_navigate(to: ~p"/organizer/occurences")

      {:ok, socket}
    end
  end

  @impl true
  def handle_event("validate", params, socket) do
    Form.handle_validate(params, socket)
  end

  @impl true
  def handle_event("save", %{"occurence" => occurence_params}, socket) do
    occurence_params = Form.normalize_for_save(occurence_params)

    case Occurences.update_occurence(socket.assigns.occurence, occurence_params) do
      {:ok, _occurence} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_navigate(to: ~p"/organizer/occurences")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
