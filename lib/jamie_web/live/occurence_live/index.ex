defmodule JamieWeb.OccurenceLive.Index do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8">
        <div class="max-w-7xl mx-auto">
          <div class="mb-6 sm:mb-8 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
              <h1 class="text-3xl sm:text-4xl font-bold">My Events</h1>
              <p class="mt-2 text-base-content/70">Manage your jam occurences</p>
            </div>
            <.link
              navigate={~p"/occurences/new"}
              class="btn btn-primary min-h-14 text-base sm:text-lg shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
            >
              <.icon name="hero-plus" class="h-5 w-5" /> Create Event
            </.link>
          </div>

          <div class="grid gap-4 sm:gap-6">
            <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-xl p-6 sm:p-8 border border-base-300">
              <h2 class="text-xl sm:text-2xl font-bold mb-4">Upcoming Events</h2>
              <%= if @upcoming_occurences == [] do %>
                <div class="text-center py-12">
                  <.icon name="hero-calendar" class="h-16 w-16 mx-auto text-base-content/30 mb-4" />
                  <p class="text-lg text-base-content/70">No upcoming events</p>
                  <p class="text-sm text-base-content/50 mt-2">
                    Create your first event to get started
                  </p>
                </div>
              <% else %>
                <div class="grid gap-4">
                  <div
                    :for={occurence <- @upcoming_occurences}
                    class="card bg-base-200 shadow-md hover:shadow-lg transition-shadow"
                  >
                    <div class="card-body">
                      <div class="flex justify-between items-start gap-4">
                        <div class="flex-1">
                          <h3 class="card-title text-lg sm:text-xl">{occurence.title}</h3>
                          <div class="mt-2 space-y-1 text-sm text-base-content/70">
                            <div class="flex items-center gap-2">
                              <.icon name="hero-calendar" class="h-4 w-4" />
                              <span>
                                {Calendar.strftime(occurence.date, "%B %d, %Y at %I:%M %p")}
                              </span>
                            </div>
                            <div :if={occurence.location} class="flex items-center gap-2">
                              <.icon name="hero-map-pin" class="h-4 w-4" />
                              <span>{occurence.location}</span>
                            </div>
                            <div :if={occurence.cost} class="flex items-center gap-2">
                              <.icon name="hero-currency-dollar" class="h-4 w-4" />
                              <span>€{occurence.cost}</span>
                            </div>
                          </div>
                          <div class="mt-3 flex flex-wrap gap-2">
                            <span class="badge badge-success">{occurence.status}</span>
                            <span :if={occurence.disabled} class="badge badge-warning">Disabled</span>
                            <span :if={occurence.is_private} class="badge badge-info">Private</span>
                          </div>
                        </div>
                        <div class="flex flex-col gap-2">
                          <.link
                            navigate={~p"/occurences/#{occurence.id}/edit"}
                            class="btn btn-sm btn-ghost"
                          >
                            <.icon name="hero-pencil" class="h-4 w-4" />
                          </.link>
                          <button
                            type="button"
                            phx-click="delete"
                            phx-value-id={occurence.id}
                            data-confirm="Are you sure you want to delete this event?"
                            class="btn btn-sm btn-ghost text-error"
                          >
                            <.icon name="hero-trash" class="h-4 w-4" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>

            <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-xl p-6 sm:p-8 border border-base-300">
              <h2 class="text-xl sm:text-2xl font-bold mb-4">Past Events</h2>
              <%= if @past_occurences == [] do %>
                <div class="text-center py-8">
                  <p class="text-base-content/50">No past events</p>
                </div>
              <% else %>
                <div class="grid gap-4">
                  <div
                    :for={occurence <- @past_occurences}
                    class="card bg-base-200/50 shadow-sm"
                  >
                    <div class="card-body">
                      <div class="flex justify-between items-start gap-4">
                        <div class="flex-1">
                          <h3 class="card-title text-lg opacity-70">{occurence.title}</h3>
                          <div class="mt-2 space-y-1 text-sm text-base-content/50">
                            <div class="flex items-center gap-2">
                              <.icon name="hero-calendar" class="h-4 w-4" />
                              <span>{Calendar.strftime(occurence.date, "%B %d, %Y")}</span>
                            </div>
                          </div>
                          <div class="mt-3">
                            <span class="badge badge-ghost">{occurence.status}</span>
                          </div>
                        </div>
                        <div class="flex flex-col gap-2">
                          <.link
                            navigate={~p"/occurences/#{occurence.id}/edit"}
                            class="btn btn-sm btn-ghost"
                          >
                            <.icon name="hero-eye" class="h-4 w-4" />
                          </.link>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    upcoming = Occurences.list_upcoming_occurences(user)
    past = Occurences.list_past_occurences(user)

    socket =
      socket
      |> assign(:upcoming_occurences, upcoming)
      |> assign(:past_occurences, past)

    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      {:ok, _} = Occurences.delete_occurence(occurence)

      socket =
        socket
        |> put_flash(:info, "Event deleted successfully")
        |> assign(:upcoming_occurences, Occurences.list_upcoming_occurences(user))
        |> assign(:past_occurences, Occurences.list_past_occurences(user))

      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "You are not authorized to delete this event")}
    end
  end
end
