defmodule JamieWeb.OccurenceLive.Participants do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen bg-gradient-to-b from-base-200 to-base-300 dark:from-slate-900 dark:to-slate-800 px-4 py-6 sm:py-8">
        <div class="max-w-7xl mx-auto">
          <div class="mb-8">
            <.link
              navigate={~p"/occurences"}
              class="text-base-content/70 hover:text-base-content text-sm mb-4 inline-flex items-center gap-2"
            >
              <.icon name="hero-arrow-left" class="h-4 w-4" /> Back to Events
            </.link>
            <h1 class="text-3xl sm:text-4xl font-bold text-base-content mt-2">{@occurence.title}</h1>
          </div>

          <div class="space-y-12">
            <section>
              <h2 class="text-2xl font-bold text-base-content mb-6">Confirmed Participants</h2>
              <%= if @confirmed_participants == [] do %>
                <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 dark:bg-slate-800/50 dark:border-slate-700/50 p-8 text-center">
                  <p class="text-base-content/70 dark:text-slate-400">No confirmed participants yet</p>
                </div>
              <% else %>
                <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 dark:bg-slate-800/50 dark:border-slate-700/50 overflow-hidden">
                  <div class="hidden md:grid grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr] gap-4 px-6 py-4 bg-base-200 dark:bg-slate-700/30 text-base-content/70 dark:text-slate-400 text-sm font-medium">
                    <div>Name</div>
                    <div>Phone</div>
                    <div>Role</div>
                    <div>Registered</div>
                    <div>Actions</div>
                  </div>

                  <div class="divide-y divide-base-300 dark:divide-slate-700/50">
                    <div
                      :for={participant <- @confirmed_participants}
                      class="px-4 py-4 md:px-6 hover:bg-base-200 dark:hover:bg-slate-700/20 transition-colors odd:bg-base-100 dark:odd:bg-slate-800/30 even:bg-base-200/50 dark:even:bg-slate-700/20"
                    >
                      <div class="md:hidden space-y-3">
                        <div class="flex justify-between items-start">
                          <div>
                            <p class="text-base-content font-semibold text-lg">
                              {participant.user.name} {participant.user.surname}
                            </p>
                            <p class="text-base-content/70 dark:text-slate-400 text-sm mt-1">
                              {participant.user.phone || "—"}
                            </p>
                          </div>
                          <button
                            type="button"
                            phx-click="delete"
                            phx-value-id={participant.id}
                            data-confirm="Are you sure you want to cancel this participant?"
                            class="p-2 rounded-lg border-2 border-red-500/50 text-red-400 hover:bg-red-500/10 transition-colors"
                          >
                            <.icon name="hero-x-mark" class="h-5 w-5" />
                          </button>
                        </div>
                        <div class="flex items-center gap-4">
                          <span class="px-3 py-1 bg-sky-500 text-white text-sm rounded-lg font-medium">
                            {participant.role}
                          </span>
                          <span class="text-base-content/70 dark:text-slate-400 text-sm">
                            {Calendar.strftime(participant.inserted_at, "%b %d, %H:%M")}
                          </span>
                        </div>
                      </div>

                      <div class="hidden md:grid grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr] gap-4 items-center">
                        <div class="text-base-content font-semibold text-lg">
                          {participant.user.name} {participant.user.surname}
                        </div>
                        <div class="text-base-content/80 dark:text-slate-300">{participant.user.phone || "—"}</div>
                        <div>
                          <span class="px-3 py-1 bg-sky-500 text-white text-sm rounded-lg font-medium">
                            {participant.role}
                          </span>
                        </div>
                        <div class="text-base-content/80 dark:text-slate-300">
                          {Calendar.strftime(participant.inserted_at, "%b %d, %H:%M")}
                        </div>
                        <div>
                          <button
                            type="button"
                            phx-click="delete"
                            phx-value-id={participant.id}
                            data-confirm="Are you sure you want to cancel this participant?"
                            class="p-2 rounded-lg border-2 border-red-500/50 text-red-400 hover:bg-red-500/10 transition-colors"
                          >
                            <.icon name="hero-x-mark" class="h-5 w-5" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </section>

            <section>
              <h2 class="text-2xl font-bold text-base-content mb-6">Waitlist</h2>
              <%= if @waitlist_participants == [] do %>
                <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 dark:bg-slate-800/50 dark:border-slate-700/50 p-8 text-center">
                  <p class="text-base-content/70 dark:text-slate-400">No participants on waitlist</p>
                </div>
              <% else %>
                <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 dark:bg-slate-800/50 dark:border-slate-700/50 overflow-hidden">
                  <div class="hidden md:grid grid-cols-[auto_2fr_1.5fr_1fr_1.5fr_1fr] gap-4 px-6 py-4 bg-base-200 dark:bg-slate-700/30 text-base-content/70 dark:text-slate-400 text-sm font-medium">
                    <div>Position</div>
                    <div>Name</div>
                    <div>Phone</div>
                    <div>Role</div>
                    <div>Added</div>
                    <div>Actions</div>
                  </div>

                  <div class="divide-y divide-base-300 dark:divide-slate-700/50">
                    <div
                      :for={{participant, index} <- Enum.with_index(@waitlist_participants, 1)}
                      class="px-4 py-4 md:px-6 hover:bg-base-200 dark:hover:bg-slate-700/20 transition-colors odd:bg-base-100 dark:odd:bg-slate-800/30 even:bg-base-200/50 dark:even:bg-slate-700/20"
                    >
                      <div class="md:hidden space-y-3">
                        <div class="flex justify-between items-start">
                          <div>
                            <div class="flex items-center gap-2 mb-1">
                              <span class="text-orange-500 font-bold text-lg">#{index}</span>
                              <p class="text-base-content font-semibold text-lg">
                                {participant.user.name} {participant.user.surname}
                              </p>
                            </div>
                            <p class="text-base-content/70 dark:text-slate-400 text-sm">{participant.user.phone || "—"}</p>
                          </div>
                        </div>
                        <div class="flex items-center gap-4 mb-3">
                          <span class="px-3 py-1 bg-sky-500 text-white text-sm rounded-lg font-medium">
                            {participant.role}
                          </span>
                          <span class="text-base-content/70 dark:text-slate-400 text-sm">
                            {Calendar.strftime(participant.inserted_at, "%b %d, %H:%M")}
                          </span>
                        </div>
                        <div class="flex gap-2">
                          <button
                            type="button"
                            phx-click="promote_from_waitlist"
                            phx-value-id={participant.id}
                            class="flex-1 p-2 rounded-lg border-2 border-teal-500/50 text-teal-400 hover:bg-teal-500/10 transition-colors flex items-center justify-center gap-2"
                          >
                            <.icon name="hero-arrow-up" class="h-5 w-5" />
                          </button>
                          <button
                            type="button"
                            phx-click="delete"
                            phx-value-id={participant.id}
                            data-confirm="Are you sure you want to cancel this participant?"
                            class="p-2 rounded-lg border-2 border-red-500/50 text-red-400 hover:bg-red-500/10 transition-colors"
                          >
                            <.icon name="hero-x-mark" class="h-5 w-5" />
                          </button>
                        </div>
                      </div>

                      <div class="hidden md:grid grid-cols-[auto_2fr_1.5fr_1fr_1.5fr_1fr] gap-4 items-center">
                        <div class="text-orange-500 font-bold text-xl">#{index}</div>
                        <div class="text-base-content font-semibold text-lg">
                          {participant.user.name} {participant.user.surname}
                        </div>
                        <div class="text-base-content/80 dark:text-slate-300">{participant.user.phone || "—"}</div>
                        <div>
                          <span class="px-3 py-1 bg-sky-500 text-white text-sm rounded-lg font-medium">
                            {participant.role}
                          </span>
                        </div>
                        <div class="text-base-content/80 dark:text-slate-300">
                          {Calendar.strftime(participant.inserted_at, "%b %d, %H:%M")}
                        </div>
                        <div class="flex gap-2">
                          <button
                            type="button"
                            phx-click="promote_from_waitlist"
                            phx-value-id={participant.id}
                            class="p-2 rounded-lg border-2 border-teal-500/50 text-teal-400 hover:bg-teal-500/10 transition-colors"
                          >
                            <.icon name="hero-arrow-up" class="h-5 w-5" />
                          </button>
                          <button
                            type="button"
                            phx-click="delete"
                            phx-value-id={participant.id}
                            data-confirm="Are you sure you want to cancel this participant?"
                            class="p-2 rounded-lg border-2 border-red-500/50 text-red-400 hover:bg-red-500/10 transition-colors"
                          >
                            <.icon name="hero-x-mark" class="h-5 w-5" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </section>

            <section>
              <h2 class="text-2xl font-bold text-base-content mb-6">Cancelled Registrations</h2>
              <%= if @cancelled_participants == [] do %>
                <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 dark:bg-slate-800/50 dark:border-slate-700/50 p-8 text-center">
                  <p class="text-base-content/70 dark:text-slate-400">No cancelled registrations</p>
                </div>
              <% else %>
                <div class="bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 dark:bg-slate-800/50 dark:border-slate-700/50 overflow-hidden">
                  <div class="hidden md:grid grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr] gap-4 px-6 py-4 bg-base-200 dark:bg-slate-700/30 text-base-content/70 dark:text-slate-400 text-sm font-medium">
                    <div>Name</div>
                    <div>Phone</div>
                    <div>Role</div>
                    <div>Cancelled</div>
                    <div>Actions</div>
                  </div>

                  <div class="divide-y divide-base-300 dark:divide-slate-700/50">
                    <div
                      :for={participant <- @cancelled_participants}
                      class="px-4 py-4 md:px-6 hover:bg-base-200 dark:hover:bg-slate-700/20 transition-colors odd:bg-base-100 dark:odd:bg-slate-800/30 even:bg-base-200/50 dark:even:bg-slate-700/20"
                    >
                      <div class="md:hidden space-y-3">
                        <div>
                          <p class="text-base-content/70 dark:text-slate-400 font-semibold text-lg">
                            {participant.user.name} {participant.user.surname}
                          </p>
                          <p class="text-base-content/60 dark:text-slate-500 text-sm mt-1">
                            {participant.user.phone || "—"}
                          </p>
                        </div>
                        <div class="flex items-center gap-4 mb-3">
                          <span class="px-3 py-1 bg-base-200 dark:bg-slate-700 border border-sky-500/30 text-sky-400 text-sm rounded-lg font-medium">
                            {participant.role}
                          </span>
                          <span class="text-base-content/70 dark:text-slate-400 text-sm">
                            {Calendar.strftime(participant.inserted_at, "%b %d, %H:%M")}
                          </span>
                        </div>
                        <button
                          type="button"
                          phx-click="promote_from_cancelled"
                          phx-value-id={participant.id}
                          class="w-full p-2 rounded-lg border-2 border-indigo-500/50 text-indigo-400 hover:bg-indigo-500/10 transition-colors flex items-center justify-center gap-2"
                        >
                          <.icon name="hero-arrow-path" class="h-5 w-5" />
                        </button>
                      </div>

                      <div class="hidden md:grid grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr] gap-4 items-center">
                        <div class="text-base-content/70 dark:text-slate-400 font-semibold text-lg">
                          {participant.user.name} {participant.user.surname}
                        </div>
                        <div class="text-base-content/60 dark:text-slate-500">{participant.user.phone || "—"}</div>
                        <div>
                          <span class="px-3 py-1 bg-base-200 dark:bg-slate-700 border border-sky-500/30 text-sky-400 text-sm rounded-lg font-medium">
                            {participant.role}
                          </span>
                        </div>
                        <div class="text-base-content/80 dark:text-slate-400">
                          {Calendar.strftime(participant.inserted_at, "%b %d, %H:%M")}
                        </div>
                        <div>
                          <button
                            type="button"
                            phx-click="promote_from_cancelled"
                            phx-value-id={participant.id}
                            class="p-2 rounded-lg border-2 border-indigo-500/50 text-indigo-400 hover:bg-indigo-500/10 transition-colors"
                          >
                            <.icon name="hero-arrow-path" class="h-5 w-5" />
                          </button>
                        </div>
                      </div>
                    </div>
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

  def mount(%{"id" => id}, _session, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      confirmed = Occurences.list_participants(occurence.id, "confirmed")
      waitlist = Occurences.list_participants(occurence.id, "waitlist")
      cancelled = Occurences.list_participants(occurence.id, "cancelled")

      socket =
        socket
        |> assign(:occurence, occurence)
        |> assign(:confirmed_participants, confirmed)
        |> assign(:waitlist_participants, waitlist)
        |> assign(:cancelled_participants, cancelled)

      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to view participants for this event")
        |> push_navigate(to: ~p"/occurences")

      {:ok, socket}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    {:ok, _} = Occurences.cancel_participant(participant)

    socket =
      socket
      |> put_flash(:info, "Participant cancelled successfully")
      |> assign(:confirmed_participants, Occurences.list_participants(occurence.id, "confirmed"))
      |> assign(:waitlist_participants, Occurences.list_participants(occurence.id, "waitlist"))
      |> assign(:cancelled_participants, Occurences.list_participants(occurence.id, "cancelled"))

    {:noreply, socket}
  end

  def handle_event("promote_from_waitlist", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    {:ok, _} = Occurences.promote_participant_to_confirmed(participant)

    socket =
      socket
      |> put_flash(:info, "Participant promoted to confirmed")
      |> assign(:confirmed_participants, Occurences.list_participants(occurence.id, "confirmed"))
      |> assign(:waitlist_participants, Occurences.list_participants(occurence.id, "waitlist"))

    {:noreply, socket}
  end

  def handle_event("promote_from_cancelled", %{"id" => id}, socket) do
    participant = Occurences.get_participant_by_id!(id)
    occurence = socket.assigns.occurence

    case Occurences.restore_participant(participant, occurence) do
      {:ok, _participant} ->
        socket =
          socket
          |> put_flash(:info, "Participant restored successfully")
          |> assign(
            :confirmed_participants,
            Occurences.list_participants(occurence.id, "confirmed")
          )
          |> assign(
            :waitlist_participants,
            Occurences.list_participants(occurence.id, "waitlist")
          )
          |> assign(
            :cancelled_participants,
            Occurences.list_participants(occurence.id, "cancelled")
          )

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to restore participant")}
    end
  end
end
