defmodule JamieWeb.OccurenceLive.Register do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8">
        <div class="max-w-2xl mx-auto">
          <div class="mb-6">
            <.link navigate={~p"/events/#{@occurence.slug}"} class="btn btn-ghost btn-sm">
              <.icon name="hero-arrow-left" class="h-4 w-4" /> Back to Event
            </.link>
          </div>

          <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl p-6 sm:p-8 border border-base-300">
            <div class="mb-6">
              <h1 class="text-2xl sm:text-3xl font-bold mb-2">{@occurence.title}</h1>
              <p class="text-base-content/70">Register for Event</p>
            </div>

            <%!-- Event summary --%>
            <div class="bg-base-200 rounded-xl p-4 mb-6">
              <div class="flex items-center gap-2 text-sm mb-2">
                <.icon name="hero-calendar-days" class="h-4 w-4 text-primary" />
                <span>{Calendar.strftime(@occurence.date, "%B %d, %Y at %I:%M %p")}</span>
              </div>
              <div :if={@occurence.location} class="flex items-center gap-2 text-sm mb-2">
                <.icon name="hero-map-pin" class="h-4 w-4 text-primary" />
                <span>{@occurence.location}</span>
              </div>
              <div class="flex items-center gap-2 text-sm">
                <.icon name="hero-currency-euro" class="h-4 w-4 text-primary" />
                <%= if @occurence.cost && Decimal.compare(@occurence.cost, Decimal.new(0)) == :gt do %>
                  <span>€{@occurence.cost}</span>
                <% else %>
                  <span class="badge badge-success gap-1">
                    Free
                  </span>
                <% end %>
              </div>
            </div>

            <%!-- Event description --%>
            <div :if={@occurence.description} class="bg-base-200 rounded-xl p-4 mb-6">
              <h3 class="font-semibold mb-2 flex items-center gap-2">
                <.icon name="hero-document-text" class="h-4 w-4 text-primary" />
                Description
              </h3>
              <div class="prose prose-sm max-w-none text-base-content/80">
                {markdown_to_html(@occurence.description)}
              </div>
            </div>

            <%!-- Registration status --%>
            <%= if @is_full do %>
              <div class="alert alert-warning mb-6">
                <.icon name="hero-exclamation-triangle" class="h-5 w-5" />
                <div>
                  <div class="font-semibold">Event is full</div>
                  <div class="text-sm">
                    You will be added to the waitlist and notified if a spot becomes available.
                  </div>
                </div>
              </div>
            <% else %>
              <div class="alert alert-success mb-6">
                <.icon name="hero-check-circle" class="h-5 w-5" />
                <div class="text-sm">Spots are available for this event!</div>
              </div>
            <% end %>

            <%!-- Registration form --%>
            <.form for={@form} id="participant-form" phx-submit="register" class="space-y-4">
              <.input
                field={@form[:role]}
                type="select"
                label="Preferred Role"
                options={[
                  {"Base", "base"},
                  {"Flyer", "flyer"}
                ]}
              />

              <%= if @occurence.show_partecipant_list do %>
                <div class="alert alert-info">
                  <.icon name="hero-information-circle" class="h-5 w-5" />
                  <div class="text-sm">
              This event displays the participant list publicly. <br/>Please provide a nickname for display.
                  </div>
                </div>

                <.input
                  field={@form[:nickname]}
                  type="text"
                  label="Public Nickname"
                  placeholder="How you want to appear in the participant list"
                  required
                />
              <% end %>

              <.input
                field={@form[:notes]}
                type="textarea"
                label="Notes (optional, visible to organizers only)"
                placeholder="Any special requirements or notes..."
                rows="3"
              />

              <div class="flex gap-3 pt-4">
                <button type="submit" class="btn btn-primary flex-1" disabled={@registering}>
                  <%= if @registering do %>
                    <span class="loading loading-spinner loading-sm"></span>
                    Registering...
                  <% else %>
                    <.icon name="hero-check-circle" class="h-5 w-5" />
                    <%= if @is_full, do: "Join Waitlist", else: "Confirm Registration" %>
                  <% end %>
                </button>
                <.link navigate={~p"/events/#{@occurence.slug}"} class="btn btn-ghost">
                  Cancel
                </.link>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(%{"slug" => slug}, _session, socket) do
    user = socket.assigns.current_user
    occurence = Occurences.get_occurence_by_slug!(slug)

    # Check if event is in the future
    now = DateTime.utc_now()

    if DateTime.compare(occurence.date, now) != :gt do
      socket =
        socket
        |> put_flash(:error, "This event has already passed. Registration is closed.")
        |> push_navigate(to: ~p"/events/#{slug}")

      {:ok, socket}
    else
      # Check if user is already registered
      if Occurences.user_registered?(occurence.id, user.id) do
        socket =
          socket
          |> put_flash(:info, "You are already registered for this event.")
          |> push_navigate(to: ~p"/events/#{slug}")

        {:ok, socket}
      else
        # Check if event is full
        initial_params = %{
          "role" => user.preferred_role || "base",
          "nickname" => user.nickname || user.name || ""
        }

        case Occurences.check_available_spots(occurence) do
          {:ok, _role} ->
            {:ok,
             socket
             |> assign(:occurence, occurence)
             |> assign(:is_full, false)
             |> assign(:registering, false)
             |> assign_form(initial_params)}

          {:error, :full} ->
            {:ok,
             socket
             |> assign(:occurence, occurence)
             |> assign(:is_full, true)
             |> assign(:registering, false)
             |> assign_form(initial_params)}
        end
      end
    end
  end

  def handle_event("register", %{"participant" => participant_params}, socket) do
    user = socket.assigns.current_user
    occurence = socket.assigns.occurence

    # Use the role from the form
    role = participant_params["role"] || user.preferred_role || "base"

    # Check if there are available spots for the chosen role
    confirmed_count = Occurences.count_confirmed_participants(occurence.id, role)
    capacity = if role == "base", do: occurence.base_capacity, else: occurence.flyer_capacity
    
    status = 
      cond do
        # Unlimited capacity
        is_nil(capacity) -> "confirmed"
        # Available spots
        confirmed_count < capacity -> "confirmed"
        # Full - add to waitlist
        true -> "waitlist"
      end

    attrs =
      participant_params
      |> Map.put("occurence_id", occurence.id)
      |> Map.put("user_id", user.id)
      |> Map.put("status", status)
      |> Map.put("role", role)

    socket = assign(socket, :registering, true)

    case Occurences.register_participant(attrs) do
      {:ok, _participant} ->
        # Update user's preferred role and nickname if provided
        user_updates = %{}
        user_updates = if participant_params["role"], do: Map.put(user_updates, "preferred_role", role), else: user_updates
        user_updates = if participant_params["nickname"] && participant_params["nickname"] != "", do: Map.put(user_updates, "nickname", participant_params["nickname"]), else: user_updates

        if map_size(user_updates) > 0 do
          Jamie.Accounts.update_user_profile(user, user_updates)
        end

        # TODO: Send email notification
        message =
          if status == "waitlist" do
            "You have been added to the waitlist. We'll notify you if a spot becomes available."
          else
            "Registration successful! You will receive a confirmation email shortly."
          end

        {:noreply,
         socket
         |> put_flash(:success, message)
         |> push_navigate(to: ~p"/events/#{occurence.slug}")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:registering, false)
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset_or_params) do
    form =
      case changeset_or_params do
        %Ecto.Changeset{} = changeset ->
          to_form(changeset)

        params ->
          %Jamie.Occurences.Participant{}
          |> Jamie.Occurences.Participant.changeset(params)
          |> to_form()
      end

    assign(socket, :form, form)
  end
end
