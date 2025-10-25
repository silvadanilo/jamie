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
      "bg-base-100/80 backdrop-blur rounded-lg border-2 border-base-300 p-3 relative shadow-md",
      @class
    ]}>
      <div class="flex justify-between items-start mb-1">
        <h3 class="text-base-content font-semibold text-xs">{@title}</h3>
        <%= if @editable && !@editing do %>
          <.edit_button
            on_edit={@on_edit}
            edit_type={@edit_type}
            edit_title={@edit_title}
          />
        <% else %>
          <.transparent_icon />
        <% end %>
      </div>

      <div class="flex items-center justify-between">
        <div>
          <%= if @editing do %>
            <.edit_form
              value={@value}
              total={@total}
              on_save={@on_save}
              on_cancel={@on_cancel}
              edit_type={@edit_type}
            />
          <% else %>
            <.value_display
              value={@value}
              total={@total}
              color={@color}
            />
          <% end %>
          <p class="text-base-content/70 text-xs mt-0">
            {@subtitle}
          </p>
        </div>
        <.icon_display icon={@icon} color={@color} />
      </div>
    </div>
    """
  end

  # Helper component for edit button
  defp edit_button(assigns) do
    ~H"""
    <button
      phx-click={@on_edit}
      phx-value-type={@edit_type}
      class="p-1 rounded-lg hover:bg-base-200 transition-colors"
      title={@edit_title}
    >
      <.icon name="hero-pencil" class="h-4 w-4 text-base-content/70" />
    </button>
    """
  end

  # Helper component for transparent icon placeholder
  defp transparent_icon(assigns) do
    ~H"""
    <div class="p-1">
      <.icon name="hero-pencil" class="h-4 w-4 text-transparent" />
    </div>
    """
  end

  # Helper component for edit form
  defp edit_form(assigns) do
    ~H"""
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
    """
  end

  # Helper component for value display
  defp value_display(assigns) do
    ~H"""
    <div class={[
      "text-4xl font-bold mb-3",
      color_class(@color)
    ]}>
      {if @total > 0, do: "#{@value}/#{@total}", else: @value}
    </div>
    """
  end

  # Helper component for icon display
  defp icon_display(assigns) do
    ~H"""
    <div class={color_class(@color)}>
      <.icon name={@icon} class="h-6 w-6" />
    </div>
    """
  end

  # Helper function to get color class
  defp color_class(color) do
    case color do
      "purple" -> "text-secondary"
      "blue" -> "text-primary"
      "orange" -> "text-warning"
      "indigo" -> "text-info"
      "violet" -> "text-secondary"
      "yellow" -> "text-warning"
      "white" -> ""
      _ -> "text-secondary"
    end
  end
end
