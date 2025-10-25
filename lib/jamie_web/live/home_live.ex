defmodule JamieWeb.HomeLive do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen">
        <section class="hero min-h-[60vh] bg-gradient-to-br from-primary/20 via-base-100 to-secondary/20">
          <div class="hero-content text-center px-4">
            <div class="max-w-3xl">
              <h1 class="text-4xl sm:text-5xl md:text-6xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                Welcome to Jamie
              </h1>
              <p class="py-6 text-lg sm:text-xl text-base-content/80 leading-relaxed">
                Your platform for discovering and organizing jam sessions.
                Connect with acroyogi, find upcoming events, and create unforgettable experiences.
              </p>
              <div class="flex flex-col sm:flex-row gap-4 justify-center">
                <%= if @current_user do %>
                  <.link
                    navigate={~p"/occurences"}
                    class="btn btn-primary btn-lg shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
                  >
                    <.icon name="hero-calendar" class="h-5 w-5" /> My Events
                  </.link>
                  <.link
                    navigate={~p"/occurences/new"}
                    class="btn btn-secondary btn-lg shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
                  >
                    <.icon name="hero-plus" class="h-5 w-5" /> Create Event
                  </.link>
                <% else %>
                  <.link
                    navigate={~p"/register"}
                    class="btn btn-primary btn-lg shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
                  >
                    Get Started <.icon name="hero-arrow-right" class="h-5 w-5 ml-2" />
                  </.link>
                  <.link
                    navigate={~p"/login"}
                    class="btn btn-outline btn-lg hover:scale-105 transition-all duration-200"
                  >
                    Sign In
                  </.link>
                <% end %>
              </div>
            </div>
          </div>
        </section>

        <section class="py-12 sm:py-16 px-4 bg-base-200/50">
          <div class="max-w-7xl mx-auto">
            <div class="text-center mb-10 sm:mb-12">
              <h2 class="text-3xl sm:text-4xl font-bold mb-4">Upcoming Public Events</h2>
              <p class="text-base-content/70 text-lg">
                Join the community and discover amazing jam sessions near you
              </p>
            </div>

            <%= if @public_occurences == [] do %>
              <div class="text-center py-12">
                <.icon name="hero-calendar-days" class="h-20 w-20 mx-auto text-base-content/30 mb-4" />
                <p class="text-xl text-base-content/70">No public events scheduled yet</p>
                <p class="text-base-content/50 mt-2">Check back soon for upcoming jam sessions!</p>
              </div>
            <% else %>
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div
                  :for={occurence <- @public_occurences}
                  class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300 hover:scale-105"
                >
                  <figure :if={occurence.photo_url} class="h-48 overflow-hidden">
                    <img
                      src={occurence.photo_url}
                      alt={occurence.title}
                      class="w-full h-full object-cover"
                    />
                  </figure>
                  <div class="card-body">
                    <h3 class="card-title text-xl">{occurence.title}</h3>

                    <div class="space-y-2 text-sm text-base-content/70">
                      <div class="flex items-center gap-2">
                        <.icon name="hero-calendar" class="h-4 w-4 shrink-0" />
                        <span>{Calendar.strftime(occurence.date, "%B %d, %Y")}</span>
                      </div>
                      <div class="flex items-center gap-2">
                        <.icon name="hero-clock" class="h-4 w-4 shrink-0" />
                        <span>{Calendar.strftime(occurence.date, "%I:%M %p")}</span>
                      </div>
                      <div :if={occurence.location} class="flex items-center gap-2">
                        <.icon name="hero-map-pin" class="h-4 w-4 shrink-0" />
                        <div class="flex-1 flex items-center gap-2">
                          <span class="truncate flex-1">{occurence.location}</span>
                          <a
                            :if={occurence.latitude && occurence.longitude}
                            href={"https://www.google.com/maps/search/?api=1&query=#{occurence.latitude},#{occurence.longitude}"}
                            target="_blank"
                            rel="noopener noreferrer"
                            class="link link-primary link-hover text-xs flex items-center gap-1 shrink-0"
                            title="Open in Google Maps"
                          >
                            <.icon name="hero-arrow-top-right-on-square" class="h-3 w-3" />
                            <span class="hidden sm:inline">Maps</span>
                          </a>
                        </div>
                      </div>
                      <div :if={occurence.cost} class="flex items-center gap-2">
                        <.icon name="hero-currency-dollar" class="h-4 w-4 shrink-0" />
                        <span>€{occurence.cost}</span>
                      </div>
                    </div>

                    <div
                      :if={
                        occurence.show_available_spots &&
                          (occurence.base_capacity || occurence.flyer_capacity)
                      }
                      class="mt-3 flex gap-2 text-xs"
                    >
                      <span :if={occurence.base_capacity} class="badge badge-outline">
                        Base: {occurence.base_capacity} spots
                      </span>
                      <span :if={occurence.flyer_capacity} class="badge badge-outline">
                        Flyer: {occurence.flyer_capacity} spots
                      </span>
                    </div>

                    <div class="card-actions justify-end mt-4">
                      <.link
                        navigate={~p"/events/#{occurence.slug}"}
                        class="btn btn-primary btn-sm"
                      >
                        View Details <.icon name="hero-arrow-right" class="h-4 w-4 ml-1" />
                      </.link>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </section>

        <section class="py-12 sm:py-16 px-4">
          <div class="max-w-5xl mx-auto">
            <div class="text-center mb-10 sm:mb-12">
              <h2 class="text-3xl sm:text-4xl font-bold mb-4">Why Jamie?</h2>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div class="text-center">
                <div class="bg-primary/10 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-calendar-days" class="h-10 w-10 text-primary" />
                </div>
                <h3 class="text-xl font-bold mb-2">Easy Organization</h3>
                <p class="text-base-content/70">
                  Create and manage your jam sessions with just a few clicks
                </p>
              </div>

              <div class="text-center">
                <div class="bg-secondary/10 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-users" class="h-10 w-10 text-secondary" />
                </div>
                <h3 class="text-xl font-bold mb-2">Community Driven</h3>
                <p class="text-base-content/70">
                  Connect with acroyogi and build your local community
                </p>
              </div>

              <div class="text-center">
                <div class="bg-accent/10 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-bell" class="h-10 w-10 text-accent" />
                </div>
                <h3 class="text-xl font-bold mb-2">Stay Updated</h3>
                <p class="text-base-content/70">
                  Get notified about new events and important updates
                </p>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    public_occurences = Occurences.list_public_occurences()

    {:ok, assign(socket, :public_occurences, public_occurences)}
  end
end
