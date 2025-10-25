defmodule JamieWeb.EventCard do
  @moduledoc """
  A reusable event card component for displaying event information in lists.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  @doc """
  Renders an event card with photo, title, details, and action buttons.

  ## Examples

      <.event_card
        occurence={@occurence}
        show_actions={true}
        actions={[
          %{type: :edit, path: ~p"/organizer/occurences/123/edit", icon: "hero-pencil"},
          %{type: :participants, path: ~p"/organizer/occurences/123/participants", icon: "hero-user-group"}
        ]}
      />
  """
  attr :occurence, :map, required: true, doc: "The occurence/event data"
  attr :show_actions, :boolean, default: false, doc: "Whether to show action buttons"
  attr :actions, :list, default: [], doc: "List of action button configurations"
  attr :variant, :string, default: "default", values: ["default", "compact", "detailed"], doc: "The card variant"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def event_card(assigns) do
    ~H"""
    <div class={[
      "card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300 hover:scale-105",
      @class
    ]}>
      <figure class="h-48 overflow-hidden">
        <img
          src={@occurence.photo_url || "/images/acroyoga-default-header.png"}
          alt={@occurence.title}
          class="w-full h-full object-cover"
        />
      </figure>

      <div class="card-body">
        <h3 class="card-title text-xl">{@occurence.title}</h3>

        <div class="space-y-2 text-sm text-base-content/70">
          <div class="flex items-center gap-2">
            <.icon name="hero-calendar" class="h-4 w-4 shrink-0" />
            <span>{Calendar.strftime(@occurence.date, "%B %d, %Y")}</span>
          </div>
          <div class="flex items-center gap-2">
            <.icon name="hero-clock" class="h-4 w-4 shrink-0" />
            <span>{Calendar.strftime(@occurence.date, "%I:%M %p")}</span>
          </div>
          <div :if={@occurence.location} class="flex items-center gap-2">
            <.icon name="hero-map-pin" class="h-4 w-4 shrink-0" />
            <div class="flex-1 flex items-center gap-2">
              <span class="truncate flex-1">{@occurence.location}</span>
              <a
                :if={@occurence.latitude && @occurence.longitude}
                href={"https://www.google.com/maps/search/?api=1&query=#{@occurence.latitude},#{@occurence.longitude}"}
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
          <div :if={@occurence.cost} class="flex items-center gap-2">
            <.icon name="hero-currency-dollar" class="h-4 w-4 shrink-0" />
            <span>€{@occurence.cost}</span>
          </div>
        </div>

        <div :if={@show_actions && @actions != []} class="card-actions justify-end mt-4">
          <%= for action <- @actions do %>
            <.link
              navigate={action.path}
              class="btn btn-primary btn-sm"
            >
              <.icon name={action.icon} class="h-4 w-4" />
              {action.label || action.type |> to_string() |> String.capitalize()}
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
