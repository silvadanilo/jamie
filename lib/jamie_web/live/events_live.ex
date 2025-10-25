defmodule JamieWeb.EventsLive do
  use JamieWeb, :live_view

  import JamieWeb.EventCard
  import JamieWeb.EmptyState
  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8 bg-base-200/50">
        <div class="max-w-7xl mx-auto">
          <div class="mb-8">
            <h1 class="text-3xl sm:text-4xl font-bold mb-2">Public Events</h1>
            <p class="text-base-content/70 text-lg">
              Discover upcoming acro yoga jams and events
            </p>
          </div>

          <div class="mb-8">
            <form phx-change="filter" phx-submit="filter" class="max-w-md">
              <div class="flex gap-2">
                <input
                  type="text"
                  name="search"
                  value={@search_filter}
                  placeholder="Search by title or location..."
                  class="input input-bordered flex-1"
                />
                <%= if @search_filter != "" do %>
                  <button
                    type="button"
                    phx-click="clear_filter"
                    class="btn btn-ghost"
                  >
                    Clear
                  </button>
                <% end %>
              </div>
            </form>
          </div>

          <%= if @events == [] do %>
            <.empty_state
              icon="hero-calendar-days"
              title="No events found"
              description={
                if @search_filter != "",
                  do: "Try adjusting your search",
                  else: "Check back soon for upcoming jam sessions!"
              }
            />
          <% else %>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <.event_card
                :for={event <- @events}
                occurence={event}
                show_actions={true}
                actions={[
                  %{
                    type: :view,
                    path: ~p"/events/#{event.slug}",
                    icon: "hero-arrow-right",
                    label: "View Details"
                  }
                ]}
              />
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    events = Occurences.list_public_occurences()

    socket =
      socket
      |> assign(:events, events)
      |> assign(:search_filter, "")

    {:ok, socket}
  end

  def handle_event("filter", %{"search" => search}, socket) do
    search = String.trim(search)
    events = Occurences.list_public_occurences(search)

    socket =
      socket
      |> assign(:events, events)
      |> assign(:search_filter, search)

    {:noreply, socket}
  end

  def handle_event("clear_filter", _params, socket) do
    events = Occurences.list_public_occurences()

    socket =
      socket
      |> assign(:events, events)
      |> assign(:search_filter, "")

    {:noreply, socket}
  end
end
