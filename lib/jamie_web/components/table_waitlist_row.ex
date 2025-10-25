defmodule JamieWeb.TableWaitlistRow do
  @moduledoc """
  A waitlist participant row component specifically designed for table layouts.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  @doc """
  Renders a waitlist participant row that fits within a table structure.

  ## Examples

      <.table_waitlist_row
        participant={participant}
        index={1}
        actions={[
          %{type: :promote, event: "promote_from_waitlist", id: participant.id, icon: "hero-arrow-up", color: "teal"},
          %{type: :delete, event: "delete", id: participant.id, icon: "hero-x-mark", color: "red", confirm: "Are you sure?"}
        ]}
      />
  """
  attr :participant, :map, required: true, doc: "The participant data"
  attr :index, :integer, required: true, doc: "The position in the waitlist"
  attr :actions, :list, default: [], doc: "List of action button configurations"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def table_waitlist_row(assigns) do
    ~H"""
    <div class={[
      "px-4 py-4 md:px-6 hover:bg-base-200/50 dark:hover:bg-base-300/20 transition-colors",
      "odd:bg-base-100/50 dark:odd:bg-base-200/20 even:bg-base-200/30 dark:even:bg-base-300/10",
      @class
    ]}>
      <!-- Mobile Layout -->
      <div class="md:hidden space-y-3">
        <div class="flex justify-between items-start">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="text-orange-500 font-bold text-lg">#{@index}</span>
              <p class="text-base-content font-semibold text-lg">
                {@participant.user.name} {@participant.user.surname}
              </p>
            </div>
            <p class="text-base-content/70 text-sm">{@participant.user.phone || "—"}</p>
          </div>
        </div>
        <div class="flex items-center gap-4 mb-3">
          <span class="px-3 py-1 bg-sky-500 text-white text-sm rounded-lg font-medium">
            {String.capitalize(@participant.role)}
          </span>
          <span class="text-base-content/70 text-sm">
            {Calendar.strftime(@participant.inserted_at, "%b %d, %H:%M")}
          </span>
        </div>
        <div class="flex gap-2">
          <%= for action <- @actions do %>
            <button
              type="button"
              phx-click={action[:event]}
              phx-value-id={action[:id]}
              data-confirm={action[:confirm]}
              class={[
                "p-2 rounded-lg border-2 transition-colors flex items-center justify-center gap-2",
                action[:color] == "red" && "border-red-500/50 text-red-400 hover:bg-red-500/10",
                action[:color] == "teal" && "border-teal-500/50 text-teal-400 hover:bg-teal-500/10",
                action[:color] == "indigo" && "border-indigo-500/50 text-indigo-400 hover:bg-indigo-500/10",
                (action[:full_width] || false) && "flex-1"
              ]}
            >
              <.icon name={action[:icon]} class="h-5 w-5" />
              {if action[:label], do: action[:label], else: ""}
            </button>
          <% end %>
        </div>
      </div>
      
    <!-- Desktop Layout - Table Structure -->
      <div class="hidden md:grid grid-cols-[auto_2fr_1.5fr_1fr_1.5fr_1fr] gap-4 items-center">
        <div class="text-orange-500 font-bold text-xl">#{@index}</div>
        <div class="text-base-content font-semibold text-lg">
          {@participant.user.name} {@participant.user.surname}
        </div>
        <div class="text-base-content/70">{@participant.user.phone || "—"}</div>
        <div>
          <span class="px-3 py-1 bg-sky-500 text-white text-sm rounded-lg font-medium">
            {String.capitalize(@participant.role)}
          </span>
        </div>
        <div class="text-base-content/70">
          {Calendar.strftime(@participant.inserted_at, "%b %d, %H:%M")}
        </div>
        <div class="flex gap-2">
          <%= for action <- @actions do %>
            <button
              type="button"
              phx-click={action[:event]}
              phx-value-id={action[:id]}
              data-confirm={action[:confirm]}
              class={[
                "p-2 rounded-lg border-2 transition-colors",
                action[:color] == "red" && "border-red-500/50 text-red-400 hover:bg-red-500/10",
                action[:color] == "teal" && "border-teal-500/50 text-teal-400 hover:bg-teal-500/10",
                action[:color] == "indigo" && "border-indigo-500/50 text-indigo-400 hover:bg-indigo-500/10"
              ]}
            >
              <.icon name={action[:icon]} class="h-5 w-5" />
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
