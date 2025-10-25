defmodule JamieWeb.OccurenceLive.FormComponent do
  use JamieWeb, :live_component

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Fill in the details for your event</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="occurence-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" required />

        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          phx-debounce="blur"
          rows="5"
        />

        <.input
          field={@form[:date]}
          type="datetime-local"
          label="Date & Time"
          required
          step="900"
        />

        <div class="fieldset mb-4">
          <label>
            <span class="label mb-2 text-base">Location</span>
            <div phx-update="ignore" id="location-autocomplete-wrapper">
              <input
                type="text"
                id="location-autocomplete-input"
                data-location-id={@form[:location].id}
                data-latitude-id={@form[:latitude].id}
                data-longitude-id={@form[:longitude].id}
                data-place-id={@form[:google_place_id].id}
                value={Phoenix.HTML.Form.normalize_value("text", @form[:location].value)}
                phx-hook="PlacesAutocomplete"
                class="w-full input input-lg text-base min-h-[3rem]"
                autocomplete="off"
                placeholder="Search for a location..."
              />
            </div>
          </label>
        </div>

        <input type="hidden" id={@form[:location].id} name={@form[:location].name} value={@form[:location].value || ""} />
        <input type="hidden" id={@form[:latitude].id} name={@form[:latitude].name} value={@form[:latitude].value || ""} />
        <input type="hidden" id={@form[:longitude].id} name={@form[:longitude].name} value={@form[:longitude].value || ""} />
        <input
          type="hidden"
          id={@form[:google_place_id].id}
          name={@form[:google_place_id].name}
          value={@form[:google_place_id].value || ""}
        />

        <.input
          field={@form[:cost]}
          type="number"
          label="Cost (€)"
          step="0.01"
          min="0"
        />

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <.input
            field={@form[:base_capacity]}
            type="number"
            label="Base Capacity"
            min="0"
            placeholder="Leave empty for unlimited"
          />
          <.input
            field={@form[:flyer_capacity]}
            type="number"
            label="Flyer Capacity"
            min="0"
            placeholder="Leave empty for unlimited"
          />
        </div>

        <.input
          field={@form[:photo_url]}
          type="text"
          label="Photo URL"
        />

        <.input
          field={@form[:subscription_message]}
          type="textarea"
          label="Subscription Message"
          phx-debounce="blur"
          rows="3"
        />

        <.input
          field={@form[:cancellation_message]}
          type="textarea"
          label="Cancellation Message"
          phx-debounce="blur"
          rows="3"
        />

        <.input
          field={@form[:sare_message]}
          type="textarea"
          label="Share Message"
          phx-debounce="blur"
          rows="3"
        />

        <.input
          field={@form[:note]}
          type="textarea"
          label="Internal Note"
          phx-debounce="blur"
          rows="2"
        />

        <.input
          field={@form[:show_available_spots]}
          type="checkbox"
          label="Show Available Spots"
        />
        <.input
          field={@form[:show_partecipant_list]}
          type="checkbox"
          label="Show Participant List"
        />
        <.input
          field={@form[:is_private]}
          type="checkbox"
          label="Private Event"
        />
        <.input
          field={@form[:disabled]}
          type="checkbox"
          label="Disabled"
        />

        <:actions>
          <.button
            phx-disable-with="Saving..."
            class="w-full sm:w-auto min-h-14 text-base sm:text-lg"
            variant="primary"
          >
            Save Event
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{occurence: occurence} = assigns, socket) do
    changeset = Occurences.change_occurence(occurence)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  def handle_event("validate", %{"occurence" => occurence_params}, socket) do
    changeset =
      socket.assigns.occurence
      |> Occurences.change_occurence(occurence_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"occurence" => occurence_params}, socket) do
    save_occurence(socket, socket.assigns.action, occurence_params)
  end

  defp save_occurence(socket, :edit, occurence_params) do
    case Occurences.update_occurence(socket.assigns.occurence, occurence_params) do
      {:ok, occurence} ->
        notify_parent({:saved, occurence})

        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_occurence(socket, :new, occurence_params) do
    occurence_params = Map.put(occurence_params, "created_by_id", socket.assigns.current_user.id)

    case Occurences.create_occurence(occurence_params) do
      {:ok, occurence} ->
        notify_parent({:saved, occurence})

        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
