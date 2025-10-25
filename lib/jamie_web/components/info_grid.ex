defmodule JamieWeb.InfoGrid do
  @moduledoc """
  A reusable info grid component for displaying event details in a structured layout.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  @doc """
  Renders an info grid with event details like date, location, cost, etc.

  ## Examples

      <.info_grid
        occurence={@occurence}
        show_available_spots={true}
        base_count={@base_count}
        flyer_count={@flyer_count}
      />
  """
  attr :occurence, :map, required: true, doc: "The occurence/event data"
  attr :show_available_spots, :boolean, default: false, doc: "Whether to show available spots section"
  attr :base_count, :integer, default: 0, doc: "Current base participant count"
  attr :flyer_count, :integer, default: 0, doc: "Current flyer participant count"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def info_grid(assigns) do
    ~H"""
    <div class={["grid sm:grid-cols-2 gap-4", @class]}>
      <!-- Date & Time -->
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
      
    <!-- Location -->
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
      
    <!-- Cost -->
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
      
    <!-- Available Spots -->
      <div :if={@show_available_spots && @occurence.base_capacity} class="p-4 bg-base-200 rounded-xl">
        <div class="text-sm text-base-content/70 mb-4 flex items-center gap-2">
          <.icon name="hero-user-group" class="h-5 w-5 text-primary" /> Available Spots
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <!-- Base Section -->
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
          
    <!-- Flyer Section -->
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
    """
  end
end
