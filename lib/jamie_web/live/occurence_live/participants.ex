defmodule JamieWeb.OccurenceLive.Participants do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  defp update_participant_in_list(participants, updated_participant) do
    Enum.map(participants, fn participant ->
      if participant.id == updated_participant.id do
        updated_participant
      else
        participant
      end
    end)
  end

  def render(assigns) do
    case assigns.live_action do
      :new ->
        ~H"""
        <Layouts.app flash={@flash} current_scope={@current_user}>
          <div class="min-h-screen px-4 py-6 sm:py-8">
            <div class="max-w-2xl mx-auto">
              <div class="mb-8">
                <.link
                  navigate={~p"/organizer/occurences/#{@occurence.id}/participants"}
                  class="text-base-content/70 hover:text-base-content text-sm mb-4 inline-flex items-center gap-2"
                >
                  <.icon name="hero-arrow-left" class="h-4 w-4" /> Back to Participants
                </.link>
                <h1 class="text-3xl sm:text-4xl font-bold text-base-content mt-2">Add Participant</h1>
                <p class="text-base-content/70 mt-2">Add a new participant to {@occurence.title}</p>
              </div>

              <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 p-8">
                <.form
                  for={@form}
                  id="participant-form"
                  phx-change="validate"
                  phx-submit="save"
                  class="space-y-6"
                >
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <.input
                        field={@form[:name]}
                        type="text"
                        label="First Name"
                        placeholder="Enter first name"
                        required
                      />
                    </div>
                    <div>
                      <.input
                        field={@form[:surname]}
                        type="text"
                        label="Last Name"
                        placeholder="Enter last name"
                        required
                      />
                    </div>
                  </div>

                  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <.input
                        field={@form[:email]}
                        type="email"
                        label="Email"
                        placeholder="Enter email address"
                      />
                      <p class="text-sm text-base-content/60 mt-1">Optional - either email or phone is required</p>
                    </div>
                    <div>
                      <.input
                        field={@form[:phone]}
                        type="tel"
                        label="Phone"
                        placeholder="Enter phone number"
                      />
                    </div>
                  </div>

                  <div>
                    <.input
                      field={@form[:role]}
                      type="select"
                      label="Role"
                      options={[{"Base", "base"}, {"Flyer", "flyer"}]}
                      required
                    />
                  </div>

                  <div>
                    <.input
                      field={@form[:notes]}
                      type="textarea"
                      label="Notes"
                      placeholder="Add any additional notes about this participant"
                      rows="3"
                    />
                  </div>

                  <div class="flex justify-end gap-4 pt-6">
                    <.link
                      navigate={~p"/organizer/occurences/#{@occurence.id}/participants"}
                      class="btn btn-ghost"
                    >
                      Cancel
                    </.link>
                    <button
                      type="submit"
                      class="btn btn-primary"
                    >
                      <.icon name="hero-plus" class="h-4 w-4 mr-2" /> Add Participant
                    </button>
                  </div>
                </.form>
              </div>
            </div>
          </div>
        </Layouts.app>
        """

      _ ->
        ~H"""
        <Layouts.app flash={@flash} current_scope={@current_user}>
          <div class="min-h-screen px-4 py-6 sm:py-8">
            <div class="max-w-7xl mx-auto">
              <div class="mb-8">
                <.header>
                  Participants - {@occurence.title}
                  <:subtitle>
                    {Calendar.strftime(@occurence.date, "%B %d, %Y at %I:%M %p")} • {@occurence.location || "Location TBD"}
                  </:subtitle>
                  <:actions>
                    <.link navigate={~p"/organizer/occurences/#{@occurence.id}/participants/new"}>
                      <.button>
                        <.icon name="hero-plus" class="w-5 h-5" /> Add Participant
                      </.button>
                    </.link>
                    <.link navigate={~p"/organizer/occurences"}>
                      <.button class="btn-ghost btn-sm">
                        <.icon name="hero-arrow-left" class="w-4 h-4" /> Back
                      </.button>
                    </.link>
                  </:actions>
                </.header>
              </div>

              <%!-- Registration Link --%>
              <div class="mb-8">
                <div class="alert shadow-2xl border-2 border-info/20 mt-6">
                  <.icon name="hero-share" class="w-6 h-6 text-info" />
                  <div class="flex-1">
                    <h3 class="font-bold">Registration Link</h3>
                    <div class="text-xs text-base-content/70">Share this link with participants to register</div>
                  </div>
                  <div class="flex gap-2 flex-1">
                    <input
                      type="text"
                      readonly
                      value={Phoenix.VerifiedRoutes.url(@socket, ~p"/events/#{@occurence.slug}/register")}
                      id="participant-share-link"
                      class="input input-bordered flex-1 font-mono text-sm min-w-0"
                    />
                    <button
                      type="button"
                      onclick="navigator.clipboard.writeText(document.getElementById('participant-share-link').value)"
                      phx-click={
                        JS.transition(
                          {"transition-all duration-200", "btn-primary", "btn-success"},
                          time: 100
                        )
                        |> JS.transition(
                          {"transition-all duration-200", "btn-success", "btn-primary"},
                          time: 1500
                        )
                      }
                      class="btn btn-primary btn-sm"
                    >
                      <.icon name="hero-clipboard-document" class="w-5 h-5" /> Copy
                    </button>
                  </div>
                </div>
              </div>

              <%!-- Statistics Cards --%>
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
                <.statistics_card
                  title="Base Registered"
                  value={@base_confirmed}
                  total={@occurence.base_capacity || 0}
                  subtitle={"#{max(0, @base_available)} spots available"}
                  icon="hero-user-group"
                  color="purple"
                  edit_title="Update Capacity"
                  editable={true}
                  editing={@editing_capacity == "base"}
                  on_edit="start_edit_capacity"
                  edit_type="base"
                  on_save="update_capacity"
                  on_cancel="cancel_edit_capacity"
                />

                <.statistics_card
                  title="Flyer Registered"
                  value={@flyer_confirmed}
                  total={@occurence.flyer_capacity || 0}
                  subtitle={"#{max(0, @flyer_available)} spots available"}
                  icon="hero-user-group"
                  color="purple"
                  edit_title="Update Capacity"
                  editable={true}
                  editing={@editing_capacity == "flyer"}
                  on_edit="start_edit_capacity"
                  edit_type="flyer"
                  on_save="update_capacity"
                  on_cancel="cancel_edit_capacity"
                />

                <.statistics_card
                  title="Total Participants"
                  value={@total_participants}
                  total={(@occurence.base_capacity || 0) + (@occurence.flyer_capacity || 0)}
                  subtitle="Confirmed registrations"
                  icon="hero-users"
                  color="white"
                />

                <.statistics_card
                  title="Waitlist"
                  value={@total_waitlist}
                  total={0}
                  subtitle={"#{@base_waitlist} base, #{@flyer_waitlist} flyer"}
                  icon="hero-clock"
                  color="orange"
                />
              </div>

              <div class="space-y-12">
                <section>
                  <h2 class="text-2xl font-bold text-base-content mb-6">Confirmed Participants</h2>
                  <%= if @confirmed_participants == [] do %>
                    <.empty_state
                      icon="hero-user-group"
                      title="No confirmed participants yet"
                      description="Participants will appear here once they register for the event"
                    />
                  <% else %>
                    <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 overflow-hidden">
                      <div class="hidden md:grid grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr] gap-4 px-6 py-4 bg-base-200 text-base-content/70 text-sm font-medium">
                        <div>Name</div>
                        <div>Phone</div>
                        <div>Role</div>
                        <div>Registered</div>
                        <div>Actions</div>
                      </div>

                      <div class="divide-y divide-base-300">
                        <.table_participant_row
                          :for={participant <- @confirmed_participants}
                          participant={participant}
                          editing_role={@editing_role == participant.id}
                          on_start_edit_role="start_edit_role"
                          on_cancel_edit_role="cancel_edit_role"
                          actions={[
                            %{
                              type: :delete,
                              event: "delete",
                              id: participant.id,
                              icon: "hero-x-mark",
                              color: "red",
                              confirm: "Are you sure you want to cancel this participant?"
                            }
                          ]}
                        />
                      </div>
                    </div>
                  <% end %>
                </section>

                <section>
                  <h2 class="text-2xl font-bold text-base-content mb-6">Waitlist</h2>
                  <%= if @waitlist_participants == [] do %>
                    <.empty_state
                      icon="hero-clock"
                      title="No participants on waitlist"
                      description="Participants will be added to the waitlist when the event is full"
                    />
                  <% else %>
                    <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 overflow-hidden">
                      <div class="hidden md:grid grid-cols-[auto_2fr_1.5fr_1fr_1.5fr_1fr] gap-4 px-6 py-4 bg-base-200 text-base-content/70 text-sm font-medium">
                        <div>Position</div>
                        <div>Name</div>
                        <div>Phone</div>
                        <div>Role</div>
                        <div>Added</div>
                        <div>Actions</div>
                      </div>

                      <div class="divide-y divide-base-300">
                        <.table_waitlist_row
                          :for={{participant, index} <- Enum.with_index(@waitlist_participants, 1)}
                          participant={participant}
                          index={index}
                          editing_role={@editing_role == participant.id}
                          on_start_edit_role="start_edit_role"
                          on_cancel_edit_role="cancel_edit_role"
                          actions={[
                            %{
                              type: :promote,
                              event: "promote_from_waitlist",
                              id: participant.id,
                              icon: "hero-arrow-up",
                              color: "teal",
                              label: "Promote",
                              full_width: true
                            },
                            %{
                              type: :delete,
                              event: "delete",
                              id: participant.id,
                              icon: "hero-x-mark",
                              color: "red",
                              confirm: "Are you sure you want to remove this participant from waitlist?"
                            }
                          ]}
                        />
                      </div>
                    </div>
                  <% end %>
                </section>

                <section>
                  <h2 class="text-2xl font-bold text-base-content mb-6">Cancelled Registrations</h2>
                  <%= if @cancelled_participants == [] do %>
                    <.empty_state
                      icon="hero-x-circle"
                      title="No cancelled registrations"
                      description="Cancelled participants will appear here"
                    />
                  <% else %>
                    <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 overflow-hidden">
                      <div class="hidden md:grid grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr] gap-4 px-6 py-4 bg-base-200 text-base-content/70 text-sm font-medium">
                        <div>Name</div>
                        <div>Phone</div>
                        <div>Role</div>
                        <div>Cancelled</div>
                        <div>Actions</div>
                      </div>

                      <div class="divide-y divide-base-300">
                        <.table_participant_row
                          :for={participant <- @cancelled_participants}
                          participant={participant}
                          variant="cancelled"
                          actions={[
                            %{
                              type: :restore,
                              event: "promote_from_cancelled",
                              id: participant.id,
                              icon: "hero-arrow-path",
                              color: "indigo",
                              label: "Restore"
                            }
                          ]}
                        />
                      </div>
                    </div>
                  <% end %>
                </section>
              </div>
            </div>
          </div>
        </Layouts.app>
        """
    end
  end

  def mount(%{"id" => id}, _session, %{assigns: %{live_action: :new}} = socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      changeset = Occurences.change_participant(%Occurences.Participant{})

      socket =
        socket
        |> assign(:occurence, occurence)
        |> assign(:form, to_form(changeset))
        |> assign(:editing_role, nil)

      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to add participants for this event")
        |> push_navigate(to: ~p"/organizer/occurences")

      {:ok, socket}
    end
  end

  def mount(%{"id" => id}, _session, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      confirmed = Occurences.list_participants(occurence.id, "confirmed")
      waitlist = Occurences.list_participants(occurence.id, "waitlist")
      cancelled = Occurences.list_participants(occurence.id, "cancelled")

      # Calculate statistics
      base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
      flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
      base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
      flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

      total_participants = length(confirmed)
      total_waitlist = length(waitlist)

      base_available = (occurence.base_capacity || 0) - base_confirmed
      flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

      socket =
        socket
        |> assign(:occurence, occurence)
        |> assign(:confirmed_participants, confirmed)
        |> assign(:waitlist_participants, waitlist)
        |> assign(:cancelled_participants, cancelled)
        |> assign(:base_confirmed, base_confirmed)
        |> assign(:flyer_confirmed, flyer_confirmed)
        |> assign(:base_waitlist, base_waitlist)
        |> assign(:flyer_waitlist, flyer_waitlist)
        |> assign(:total_participants, total_participants)
        |> assign(:total_waitlist, total_waitlist)
        |> assign(:base_available, base_available)
        |> assign(:flyer_available, flyer_available)
        |> assign(:editing_capacity, nil)
        |> assign(:editing_role, nil)

      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to view participants for this event")
        |> push_navigate(to: ~p"/organizer/occurences")

      {:ok, socket}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    {:ok, _} = Occurences.cancel_participant(participant)

    # Recalculate statistics
    confirmed = Occurences.list_participants(occurence.id, "confirmed")
    waitlist = Occurences.list_participants(occurence.id, "waitlist")
    cancelled = Occurences.list_participants(occurence.id, "cancelled")

    base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
    flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
    base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
    flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

    total_participants = length(confirmed)
    total_waitlist = length(waitlist)

    base_available = (occurence.base_capacity || 0) - base_confirmed
    flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

    socket =
      socket
      |> put_flash(:info, "Participant cancelled successfully")
      |> assign(:confirmed_participants, confirmed)
      |> assign(:waitlist_participants, waitlist)
      |> assign(:cancelled_participants, cancelled)
      |> assign(:base_confirmed, base_confirmed)
      |> assign(:flyer_confirmed, flyer_confirmed)
      |> assign(:base_waitlist, base_waitlist)
      |> assign(:flyer_waitlist, flyer_waitlist)
      |> assign(:total_participants, total_participants)
      |> assign(:total_waitlist, total_waitlist)
      |> assign(:base_available, base_available)
      |> assign(:flyer_available, flyer_available)

    {:noreply, socket}
  end

  def handle_event("promote_from_waitlist", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    {:ok, _} = Occurences.promote_participant_to_confirmed(participant)

    # Recalculate statistics
    confirmed = Occurences.list_participants(occurence.id, "confirmed")
    waitlist = Occurences.list_participants(occurence.id, "waitlist")

    base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
    flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
    base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
    flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

    total_participants = length(confirmed)
    total_waitlist = length(waitlist)

    base_available = (occurence.base_capacity || 0) - base_confirmed
    flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

    socket =
      socket
      |> put_flash(:info, "Participant promoted to confirmed")
      |> assign(:confirmed_participants, confirmed)
      |> assign(:waitlist_participants, waitlist)
      |> assign(:base_confirmed, base_confirmed)
      |> assign(:flyer_confirmed, flyer_confirmed)
      |> assign(:base_waitlist, base_waitlist)
      |> assign(:flyer_waitlist, flyer_waitlist)
      |> assign(:total_participants, total_participants)
      |> assign(:total_waitlist, total_waitlist)
      |> assign(:base_available, base_available)
      |> assign(:flyer_available, flyer_available)

    {:noreply, socket}
  end

  def handle_event("promote_from_cancelled", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    case Occurences.restore_participant(participant, occurence) do
      {:ok, _participant} ->
        # Recalculate statistics
        confirmed = Occurences.list_participants(occurence.id, "confirmed")
        waitlist = Occurences.list_participants(occurence.id, "waitlist")
        cancelled = Occurences.list_participants(occurence.id, "cancelled")

        base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
        flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
        base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
        flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

        total_participants = length(confirmed)
        total_waitlist = length(waitlist)

        base_available = (occurence.base_capacity || 0) - base_confirmed
        flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

        socket =
          socket
          |> put_flash(:info, "Participant restored successfully")
          |> assign(:confirmed_participants, confirmed)
          |> assign(:waitlist_participants, waitlist)
          |> assign(:cancelled_participants, cancelled)
          |> assign(:base_confirmed, base_confirmed)
          |> assign(:flyer_confirmed, flyer_confirmed)
          |> assign(:base_waitlist, base_waitlist)
          |> assign(:flyer_waitlist, flyer_waitlist)
          |> assign(:total_participants, total_participants)
          |> assign(:total_waitlist, total_waitlist)
          |> assign(:base_available, base_available)
          |> assign(:flyer_available, flyer_available)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to restore participant")}
    end
  end

  def handle_event("start_edit_capacity", %{"type" => type}, socket) do
    {:noreply, assign(socket, :editing_capacity, type)}
  end

  def handle_event("cancel_edit_capacity", _params, socket) do
    {:noreply, assign(socket, :editing_capacity, nil)}
  end

  def handle_event("update_capacity", %{"type" => type, "capacity" => capacity}, socket) do
    occurence = socket.assigns.occurence
    capacity_int = String.to_integer(capacity)

    attrs =
      case type do
        "base" -> %{base_capacity: capacity_int}
        "flyer" -> %{flyer_capacity: capacity_int}
      end

    case Occurences.update_occurence(occurence, attrs) do
      {:ok, updated_occurence} ->
        # Recalculate statistics
        confirmed = Occurences.list_participants(updated_occurence.id, "confirmed")
        waitlist = Occurences.list_participants(updated_occurence.id, "waitlist")

        base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
        flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
        base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
        flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

        total_participants = length(confirmed)
        total_waitlist = length(waitlist)

        base_available = (updated_occurence.base_capacity || 0) - base_confirmed
        flyer_available = (updated_occurence.flyer_capacity || 0) - flyer_confirmed

        socket =
          socket
          |> put_flash(:info, "Capacity updated successfully")
          |> assign(:occurence, updated_occurence)
          |> assign(:base_confirmed, base_confirmed)
          |> assign(:flyer_confirmed, flyer_confirmed)
          |> assign(:base_waitlist, base_waitlist)
          |> assign(:flyer_waitlist, flyer_waitlist)
          |> assign(:total_participants, total_participants)
          |> assign(:total_waitlist, total_waitlist)
          |> assign(:base_available, base_available)
          |> assign(:flyer_available, flyer_available)
          |> assign(:editing_capacity, nil)
          |> assign(:editing_role, nil)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update capacity")}
    end
  end

  def handle_event("validate", %{"participant" => participant_params}, socket) do
    changeset =
      %Occurences.Participant{}
      |> Occurences.change_participant(participant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"participant" => participant_params}, socket) do
    occurence = socket.assigns.occurence

    # Create participant directly with contact info (no user creation)
    participant_params =
      participant_params
      |> Map.put("occurence_id", occurence.id)
      |> Map.put("status", "confirmed")

    case Occurences.create_participant(participant_params) do
      {:ok, _participant} ->
        socket =
          socket
          |> put_flash(:info, "Participant added successfully")
          |> push_navigate(to: ~p"/organizer/occurences/#{occurence.id}/participants")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("start_edit_role", %{"id" => id}, socket) do
    {:noreply, assign(socket, :editing_role, id)}
  end

  def handle_event("cancel_edit_role", _params, socket) do
    {:noreply, assign(socket, :editing_role, nil)}
  end

  def handle_event("update_role", %{"participant_id" => id, "role" => role}, socket) do
    participant = Occurences.get_participant_by_id!(id)

    case Occurences.update_participant_role(participant, role) do
      {:ok, updated_participant} ->
        # Update the specific participant in the lists instead of reloading all
        confirmed = update_participant_in_list(socket.assigns.confirmed_participants, updated_participant)
        waitlist = update_participant_in_list(socket.assigns.waitlist_participants, updated_participant)
        cancelled = update_participant_in_list(socket.assigns.cancelled_participants, updated_participant)

        base_confirmed = Enum.count(confirmed, &(&1.role == "base"))
        flyer_confirmed = Enum.count(confirmed, &(&1.role == "flyer"))
        base_waitlist = Enum.count(waitlist, &(&1.role == "base"))
        flyer_waitlist = Enum.count(waitlist, &(&1.role == "flyer"))

        total_participants = length(confirmed)
        total_waitlist = length(waitlist)

        occurence = socket.assigns.occurence
        base_available = (occurence.base_capacity || 0) - base_confirmed
        flyer_available = (occurence.flyer_capacity || 0) - flyer_confirmed

        socket =
          socket
          |> assign(:confirmed_participants, confirmed)
          |> assign(:waitlist_participants, waitlist)
          |> assign(:cancelled_participants, cancelled)
          |> assign(:base_confirmed, base_confirmed)
          |> assign(:flyer_confirmed, flyer_confirmed)
          |> assign(:base_waitlist, base_waitlist)
          |> assign(:flyer_waitlist, flyer_waitlist)
          |> assign(:total_participants, total_participants)
          |> assign(:total_waitlist, total_waitlist)
          |> assign(:base_available, base_available)
          |> assign(:flyer_available, flyer_available)
          |> assign(:editing_role, nil)
          |> put_flash(:info, "Participant role updated successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update participant role")}
    end
  end
end
