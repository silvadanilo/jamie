defmodule JamieWeb.EmptyState do
  @moduledoc """
  A reusable empty state component for displaying when lists or sections are empty.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  @doc """
  Renders an empty state with icon, title, description, and optional action.

  ## Examples

      <.empty_state
        icon="hero-calendar-days"
        title="No upcoming events"
        description="Create your first event to get started"
        action={%{label: "Create Event", path: ~p"/organizer/occurences/new"}}
      />

      <.empty_state
        icon="hero-users"
        title="No participants yet"
        description="Be the first to register!"
      />
  """
  attr :icon, :string, required: true, doc: "The heroicon name"
  attr :title, :string, required: true, doc: "The main title"
  attr :description, :string, required: true, doc: "The description text"
  attr :action, :map, default: nil, doc: "Optional action button configuration"
  attr :variant, :string, default: "default", values: ["default", "centered", "compact"], doc: "The empty state variant"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def empty_state(assigns) do
    ~H"""
    <div class={[
      "text-center py-12",
      @variant == "centered" && "flex flex-col items-center justify-center min-h-[200px]",
      @variant == "compact" && "py-8",
      @class
    ]}>
      <.icon name={@icon} class="h-20 w-20 mx-auto text-base-content/30 mb-4" />
      <p class="text-xl text-base-content/70 mb-2">{@title}</p>
      <p class="text-base-content/50">{@description}</p>

      <.link
        :if={@action && @action.path}
        navigate={@action.path}
        class="btn btn-primary mt-4"
      >
        {if @action && @action.icon, do: ~H"<.icon name={@action.icon} class='h-5 w-5 mr-2' />", else: ""}
        {if @action && @action.label, do: @action.label, else: ""}
      </.link>
    </div>
    """
  end
end
