defmodule JamieWeb.StatisticsCard do
  @moduledoc """
  A reusable statistics card component for displaying metrics with optional edit functionality.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  @doc """
  Renders a statistics card with title, value, subtitle, and optional edit functionality.

  ## Examples

      <.statistics_card
        title="Base Registered"
        value={@base_confirmed}
        total={@occurence.base_capacity}
        subtitle="5 spots available"
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
  """
  attr :title, :string, required: true, doc: "The card title"
  attr :value, :integer, required: true, doc: "The current value"
  attr :total, :integer, default: 0, doc: "The total/maximum value"
  attr :subtitle, :string, required: true, doc: "The subtitle text"
  attr :icon, :string, required: true, doc: "The heroicon name"
  attr :color, :string, default: "purple", doc: "The color theme (purple, cyan, orange, etc.)"
  attr :edit_title, :string, default: "Update", doc: "the title for the edit button"
  attr :editable, :boolean, default: false, doc: "Whether the card is editable"
  attr :editing, :boolean, default: false, doc: "Whether the card is currently being edited"
  attr :on_edit, :string, doc: "The event to trigger when edit button is clicked"
  attr :edit_type, :string, doc: "The type parameter for edit events"
  attr :on_save, :string, doc: "The event to trigger when saving"
  attr :on_cancel, :string, doc: "The event to trigger when canceling edit"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def statistics_card(assigns) do
    ~H"""
    <div class={[
      "bg-base-100/80 backdrop-blur rounded-2xl border border-base-300 p-6 relative",
      @class
    ]}>
      <div class="flex justify-between items-start mb-4">
        <h3 class="text-base-content font-semibold text-lg">{@title}</h3>
        <button
          :if={@editable && !@editing}
          phx-click={@on_edit}
          phx-value-type={@edit_type}
          class="p-1 rounded-lg hover:bg-base-200 transition-colors"
          title={@edit_title}
        >
          <.icon name="hero-pencil" class="h-4 w-4 text-base-content/70" />
        </button>
      </div>

      <div class="flex items-center justify-between">
        <div>
          <%= if @editing do %>
            <form phx-submit={@on_save} phx-value-type={@edit_type} class="flex items-center gap-2">
              <span class="text-base-content text-2xl font-bold">{@value}/</span>
              <input
                type="number"
                name="capacity"
                value={@total}
                min="0"
                class="w-16 px-2 py-1 bg-base-200 border border-base-300 rounded text-base-content text-2xl font-bold text-center focus:outline-none focus:ring-2 focus:ring-primary"
                autofocus
              />
              <div class="flex gap-1">
                <button
                  type="submit"
                  class="p-1 rounded hover:bg-green-500/20 transition-colors"
                  title="Save"
                >
                  <.icon name="hero-check" class="h-4 w-4 text-green-500" />
                </button>
                <button
                  type="button"
                  phx-click={@on_cancel}
                  class="p-1 rounded hover:bg-red-500/20 transition-colors"
                  title="Cancel"
                >
                  <.icon name="hero-x-mark" class="h-4 w-4 text-red-500" />
                </button>
              </div>
            </form>
          <% else %>
            <div class={[
              "text-3xl font-bold",
              @color == "purple" && "text-secondary",
              @color == "white" && "",
              @color == "orange" && "text-warning",
              @color == "indigo" && "text-info",
              @color == "violet" && "text-secondary",
              @color == "yellow" && "text-warning"
            ]}>
              {@value}/{@total}
            </div>
          <% end %>
          <p class="text-base-content/70 text-sm mt-1">
            {@subtitle}
          </p>
        </div>
        <div class={[
          @color == "purple" && "text-secondary",
          @color == "blue" && "text-primary",
          @color == "orange" && "text-warning",
          @color == "indigo" && "text-info",
          @color == "violet" && "text-secondary",
          @color == "yellow" && "text-warning"
        ]}>
          <.icon name={@icon} class="h-8 w-8" />
        </div>
      </div>
    </div>
    """
  end
end
