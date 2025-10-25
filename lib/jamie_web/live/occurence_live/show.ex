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
              <div class="h-48 sm:h-64 bg-gradient-to-r from-primary to-secondary flex items-center justify-center"></div>
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
                    <.icon name="hero-currency-euro" class="h-4 w-4" /> Free
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
                      <.icon name="hero-map" class="h-4 w-4" /> View on Maps
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

                <div :if={@occurence.show_available_spots && @occurence.base_capacity} class="p-4 bg-base-200 rounded-xl">
                  <div class="text-sm text-base-content/70 mb-4 flex items-center gap-2">
                    <.icon name="hero-user-group" class="h-5 w-5 text-primary" /> Available Spots
                  </div>
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <%!-- Base Section --%>
                    <div class="flex flex-col items-center">
                      <div class="text-white font-bold text-sm mb-1">Base</div>
                      <% base_available = @occurence.base_capacity - @base_count %>
                      <div class={[
                        "px-4 py-2 rounded-lg font-bold text-white text-center min-w-[100px] text-sm",
                        cond do
                          base_available == 0 -> "bg-red-500"
                          base_available < 3 -> "bg-yellow-500"
                          true -> "bg-teal-500"
                        end
                      ]}>
                        {base_available} / {@occurence.base_capacity}
                      </div>
                    </div>

                    <%!-- Flyer Section --%>
                    <%= if @occurence.flyer_capacity do %>
                      <div class="flex flex-col items-center">
                        <div class="text-white font-bold text-sm mb-1">Flyer</div>
                        <% flyer_available = @occurence.flyer_capacity - @flyer_count %>
                        <div class={[
                          "px-4 py-2 rounded-lg font-bold text-white text-center min-w-[100px] text-sm",
                          cond do
                            flyer_available == 0 -> "bg-red-500"
                            flyer_available < 3 -> "bg-yellow-500"
                            true -> "bg-teal-500"
                          end
                        ]}>
                          {flyer_available} / {@occurence.flyer_capacity}
                        </div>
                      </div>
                    <% end %>
                  </div>
                </div>
              </div>

              <%!-- Description --%>
              <div :if={@occurence.description} class="mb-8">
                <h2 class="text-xl font-semibold mb-3 flex items-center gap-2">
                  <.icon name="hero-document-text" class="h-5 w-5" /> Description
                </h2>
                <div class="prose prose-sm max-w-none text-base-content/80">
                  {markdown_to_html(@occurence.description)}
                </div>
              </div>

              <%!-- Participant List --%>
              <div :if={@occurence.show_partecipant_list} class="mb-8">
                <h2 class="text-xl font-semibold mb-3 flex items-center gap-2">
                  <.icon name="hero-users" class="h-5 w-5" /> Participants ({length(@participants)} registered)
                </h2>
                <div class="bg-base-200 rounded-xl p-4">
                  <%= if @participants == [] do %>
                    <p class="text-base-content/60 text-center py-4">
                      No participants yet. Be the first to register!
                    </p>
                  <% else %>
                    <div class="grid sm:grid-cols-2 gap-3">
                      <div
                        :for={participant <- @participants}
                        class="flex items-center gap-3 p-3 bg-base-100 rounded-lg"
                      >
                        <div class="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-content flex items-center justify-center font-semibold text-base">
                          {String.upcase(String.first(participant.nickname || participant.user.name || "?"))}
                        </div>
                        <div class="flex-1 min-w-0">
                          <div class="font-semibold truncate">
                            {participant.nickname || participant.user.name}
                          </div>
                          <div class="flex items-center gap-2 text-sm text-base-content/70">
                            <span class="badge badge-sm badge-ghost">
                              {String.capitalize(participant.role)}
                            </span>
                            <span
                              :if={participant.status == "waitlist"}
                              class="badge badge-sm badge-warning"
                            >
                              Waitlist
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>

              <%!-- Action buttons --%>
              <div class="flex flex-wrap gap-3 pt-6 border-t border-base-300">
                <%= if @current_user do %>
                  <.link
                    navigate={~p"/events/#{@occurence.slug}/register"}
                    class="btn btn-primary flex-1 sm:flex-none"
                  >
                    <.icon name="hero-check-circle" class="h-5 w-5" /> Register for Event
                  </.link>
                <% else %>
                  <.link navigate={~p"/login"} class="btn btn-primary flex-1 sm:flex-none">
                    <.icon name="hero-arrow-right-on-rectangle" class="h-5 w-5" /> Sign in to Register
                  </.link>
                <% end %>
                <button class="btn btn-ghost">
                  <.icon name="hero-share" class="h-5 w-5" /> Share
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
    participants = Occurences.list_participants(occurence.id, "confirmed")

    # Count confirmed participants by role (single query)
    counts = Occurences.count_confirmed_by_role(occurence.id)
    base_count = Map.get(counts, "base", 0)
    flyer_count = Map.get(counts, "flyer", 0)

    {:ok,
     socket
     |> assign(:occurence, occurence)
     |> assign(:participants, participants)
     |> assign(:base_count, base_count)
     |> assign(:flyer_count, flyer_count)}
  end
end
