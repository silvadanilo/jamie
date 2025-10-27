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
            <form phx-change="filter" phx-submit="filter" class="max-w-4xl">
              <div class="flex flex-col sm:flex-row gap-4">
                <input
                  type="text"
                  name="search"
                  value={@search_filter}
                  placeholder="Search by title or location..."
                  class="input input-bordered w-full sm:w-80"
                />

                <div class="relative flex-grow">
                  <%= if @date_from != "" and @date_to != "" do %>
                    <button
                      type="button"
                      id="clear-date-range"
                      class="absolute right-3 top-1/2 -translate-y-1/2 z-20 hover:bg-base-200 rounded-full p-1 text-base-content/60 hover:text-base-content"
                      phx-click="clear_date_range"
                      title="Clear date range"
                    >
                      <.icon name="hero-x-mark" class="h-5 w-5" />
                    </button>
                  <% end %>
                  <div id="date-range-picker-container" phx-hook="DateRangePicker" class="relative" phx-update="ignore" data-date-from={@date_from} data-date-to={@date_to}>
                    <input
                      type="text"
                      id="date-range-display"
                      placeholder="Select date range"
                      value={if @date_from != "" and @date_to != "", do: "#{@date_from} - #{@date_to}", else: ""}
                      class="input input-bordered flex-1 w-full cursor-pointer pr-10"
                      readonly
                    />
                    <input
                      type="hidden"
                      name="date_from"
                      value={@date_from}
                      phx-debounce="500"
                    />
                    <input
                      type="hidden"
                      name="date_to"
                      value={@date_to}
                      phx-debounce="500"
                    />
                    <div id="calendar-popup" class="hidden absolute top-full left-0 mt-2 z-50 shadow-xl">
                      <calendar-range months="2" class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
                        <div class="grid grid-cols-2" style="min-width: 600px;">
                          <div class="p-4">
                            <calendar-month></calendar-month>
                          </div>
                          <div class="p-4 border-l border-base-300">
                            <calendar-month offset="1"></calendar-month>
                          </div>
                        </div>
                      </calendar-range>
                    </div>
                  </div>
                </div>

                <%= if @search_filter != "" or @date_from != "" or @date_to != "" do %>
                  <button
                    type="button"
                    phx-click="clear_filter"
                    class="btn btn-ghost flex-shrink-0"
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
      |> assign(:date_from, "")
      |> assign(:date_to, "")

    {:ok, socket}
  end

  def handle_event("filter", %{"search" => search, "date_from" => date_from, "date_to" => date_to}, socket) do
    search = String.trim(search)
    date_from = String.trim(date_from)
    date_to = String.trim(date_to)

    # Convert date strings to datetime if provided
    date_from_dt =
      if date_from != "", do: date_from |> Date.from_iso8601!() |> DateTime.new!(~T[00:00:00], "Etc/UTC"), else: nil

    date_to_dt =
      if date_to != "", do: date_to |> Date.from_iso8601!() |> DateTime.new!(~T[23:59:59], "Etc/UTC"), else: nil

    events = Occurences.list_public_occurences(search, date_from_dt, date_to_dt)

    socket =
      socket
      |> assign(:events, events)
      |> assign(:search_filter, search)
      |> assign(:date_from, date_from)
      |> assign(:date_to, date_to)

    {:noreply, socket}
  end

  def handle_event("clear_filter", _params, socket) do
    events = Occurences.list_public_occurences()

    socket =
      socket
      |> assign(:events, events)
      |> assign(:search_filter, "")
      |> assign(:date_from, "")
      |> assign(:date_to, "")

    {:noreply, socket}
  end

  def handle_event("clear_date_range", _params, socket) do
    search = socket.assigns.search_filter

    # Re-fetch events without date filter
    date_from_dt = nil
    date_to_dt = nil
    events = Occurences.list_public_occurences(search, date_from_dt, date_to_dt)

    socket =
      socket
      |> assign(:events, events)
      |> assign(:date_from, "")
      |> assign(:date_to, "")

    {:noreply, socket}
  end
end
