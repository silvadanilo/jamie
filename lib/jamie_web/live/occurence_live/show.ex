defmodule JamieWeb.OccurenceLive.Show do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8">
        <div class="max-w-4xl mx-auto">
          <div class="mb-6">
            <.link navigate={~p"/"} class="btn btn-ghost btn-sm">
              <.icon name="hero-arrow-left" class="h-4 w-4" /> Back to Events
            </.link>
          </div>

          <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl overflow-hidden border border-base-300">
            <%!-- Header with photo or gradient --%>
            <%= if @occurence.photo_url do %>
              <div class="relative h-48 sm:h-64">
                <img src={@occurence.photo_url} alt={@occurence.title} class="w-full h-full object-cover" />
                <div class="absolute inset-0 bg-gradient-to-t from-base-100/50 to-transparent"></div>
              </div>
            <% else %>
              <div class="h-48 sm:h-64 bg-gradient-to-r from-primary to-secondary flex items-center justify-center">
              </div>
            <% end %>

            <%!-- Content --%>
            <div class="p-6 sm:p-8">
              <%!-- Title and badges --%>
              <div class="mb-6">
                <h1 class="text-3xl sm:text-4xl font-bold mb-3">{@occurence.title}</h1>
                <div class="flex flex-wrap gap-2">
                  <span class="badge badge-lg badge-primary">{@occurence.status}</span>
                  <span :if={@occurence.is_private} class="badge badge-lg badge-info">Private Event</span>
                  <span :if={@occurence.disabled} class="badge badge-lg badge-warning">Disabled</span>
                  <span
                    :if={!@occurence.cost || Decimal.compare(@occurence.cost, Decimal.new(0)) != :gt}
                    class="badge badge-lg badge-success gap-1"
                  >
                    <.icon name="hero-currency-euro" class="h-4 w-4" />
                    Free
                  </span>
                </div>
              </div>

              <%!-- Key information grid --%>
              <div class="grid sm:grid-cols-2 gap-4 mb-8">
                <div class="flex items-start gap-3 p-4 bg-base-200 rounded-xl">
                  <div class="flex-shrink-0">
                    <.icon name="hero-calendar-days" class="h-6 w-6 text-primary" />
                  </div>
                  <div>
                    <div class="text-sm text-base-content/70">Date & Time</div>
                    <div class="font-semibold">
                      {Calendar.strftime(@occurence.date, "%B %d, %Y")}
                    </div>
                    <div class="text-sm">
                      {Calendar.strftime(@occurence.date, "%I:%M %p")}
                    </div>
                  </div>
                </div>

                <div :if={@occurence.location} class="flex items-start gap-3 p-4 bg-base-200 rounded-xl">
                  <div class="flex-shrink-0">
                    <.icon name="hero-map-pin" class="h-6 w-6 text-primary" />
                  </div>
                  <div class="flex-1 min-w-0">
                    <div class="text-sm text-base-content/70">Location</div>
                    <div class="font-semibold">{@occurence.location}</div>
                    <a
                      :if={@occurence.latitude && @occurence.longitude}
                      href={"https://www.google.com/maps/search/?api=1&query=#{@occurence.latitude},#{@occurence.longitude}"}
                      target="_blank"
                      rel="noopener noreferrer"
                      class="text-sm text-primary hover:underline flex items-center gap-1 mt-1"
                    >
                      <.icon name="hero-map" class="h-4 w-4" />
                      View on Maps
                    </a>
                  </div>
                </div>

                <%= if @occurence.cost && Decimal.compare(@occurence.cost, Decimal.new(0)) == :gt do %>
                  <div class="flex items-start gap-3 p-4 bg-base-200 rounded-xl">
                    <div class="flex-shrink-0">
                      <.icon name="hero-currency-euro" class="h-6 w-6 text-primary" />
                    </div>
                    <div>
                      <div class="text-sm text-base-content/70">Cost</div>
                      <div class="font-semibold">€{@occurence.cost}</div>
                    </div>
                  </div>
                <% end %>

                <div :if={@occurence.show_available_spots && @occurence.base_capacity} class="flex items-start gap-3 p-4 bg-base-200 rounded-xl">
                  <div class="flex-shrink-0">
                    <.icon name="hero-user-group" class="h-6 w-6 text-primary" />
                  </div>
                  <div>
                    <div class="text-sm text-base-content/70">Available Spots</div>
                    <div class="font-semibold">{@occurence.base_capacity} spots</div>
                    <div :if={@occurence.flyer_capacity} class="text-sm text-base-content/60">
                      + {@occurence.flyer_capacity} flyer spots
                    </div>
                  </div>
                </div>
              </div>

              <%!-- Description --%>
              <div :if={@occurence.description} class="mb-8">
                <h2 class="text-xl font-semibold mb-3 flex items-center gap-2">
                  <.icon name="hero-document-text" class="h-5 w-5" />
                  Description
                </h2>
                <div class="prose prose-sm max-w-none text-base-content/80">
                  {markdown_to_html(@occurence.description)}
                </div>
              </div>

              <%!-- Participant List --%>
              <div :if={@occurence.show_partecipant_list} class="mb-8">
                <h2 class="text-xl font-semibold mb-3 flex items-center gap-2">
                  <.icon name="hero-users" class="h-5 w-5" />
                  Participants
                </h2>
                <div class="bg-base-200 rounded-xl p-4">
                  <%!-- TODO: Implement participant list when participants feature is added --%>
                  <p class="text-base-content/60 text-center py-4">
                    Participant list will be displayed here
                  </p>
                </div>
              </div>

              <%!-- Action buttons --%>
              <div class="flex flex-wrap gap-3 pt-6 border-t border-base-300">
                <%= if @current_user do %>
                  <.link
                    navigate={~p"/events/#{@occurence.slug}/register"}
                    class="btn btn-primary flex-1 sm:flex-none"
                  >
                    <.icon name="hero-check-circle" class="h-5 w-5" />
                    Register for Event
                  </.link>
                <% else %>
                  <.link navigate={~p"/login"} class="btn btn-primary flex-1 sm:flex-none">
                    <.icon name="hero-arrow-right-on-rectangle" class="h-5 w-5" />
                    Sign in to Register
                  </.link>
                <% end %>
                <button class="btn btn-ghost">
                  <.icon name="hero-share" class="h-5 w-5" />
                  Share
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(%{"slug" => slug}, _session, socket) do
    occurence = Occurences.get_occurence_by_slug!(slug)

    {:ok, assign(socket, :occurence, occurence)}
  end
end
