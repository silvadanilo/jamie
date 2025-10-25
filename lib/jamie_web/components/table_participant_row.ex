defmodule JamieWeb.TableParticipantRow do
  @moduledoc """
  A participant row component specifically designed for table layouts.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  @doc """
  Renders a participant row that fits within a table structure.

  ## Examples

      <.table_participant_row
        participant={participant}
        actions={[
          %{type: :delete, event: "delete", id: participant.id, icon: "hero-x-mark", color: "red", confirm: "Are you sure?"}
        ]}
      />
  """
  attr :participant, :map, required: true, doc: "The participant data"
  attr :actions, :list, default: [], doc: "List of action button configurations"
  attr :variant, :string, default: "default", values: ["default", "cancelled"], doc: "The row variant"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def table_participant_row(assigns) do
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
            <p class={[
              "font-semibold text-lg",
              @variant == "cancelled" && "text-base-content/60"
            ]}>
              {@participant.user.name} {@participant.user.surname}
            </p>
            <p class={[
              "text-sm mt-1",
              @variant == "cancelled" && "text-base-content/50",
              @variant != "cancelled" && "text-base-content/70"
            ]}>
              {@participant.user.phone || "—"}
            </p>
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
        <div class="flex items-center gap-4 mb-3">
          <span class={[
            "px-3 py-1 text-sm rounded-lg font-medium",
            @variant == "cancelled" && "bg-base-200 border border-sky-500/30 text-sky-500",
            @variant != "cancelled" && "bg-sky-500 text-white"
          ]}>
            {String.capitalize(@participant.role)}
          </span>
          <span class={[
            "text-sm",
            @variant == "cancelled" && "text-base-content/60",
            @variant != "cancelled" && "text-base-content/70"
          ]}>
            {Calendar.strftime(@participant.inserted_at, "%b %d, %H:%M")}
          </span>
        </div>
      </div>
      
    <!-- Desktop Layout - Table Structure -->
      <div class="hidden md:grid grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr] gap-4 items-center">
        <div class={[
          "font-semibold text-lg",
          @variant == "cancelled" && "text-base-content/60"
        ]}>
          {@participant.user.name} {@participant.user.surname}
        </div>
        <div class={[
          @variant == "cancelled" && "text-base-content/50",
          @variant != "cancelled" && "text-base-content/70"
        ]}>
          {@participant.user.phone || "—"}
        </div>
        <div>
          <span class={[
            "px-3 py-1 text-sm rounded-lg font-medium",
            @variant == "cancelled" && "bg-base-200 border border-sky-500/30 text-sky-500",
            @variant != "cancelled" && "bg-sky-500 text-white"
          ]}>
            {String.capitalize(@participant.role)}
          </span>
        </div>
        <div class={[
          @variant == "cancelled" && "text-base-content/60",
          @variant != "cancelled" && "text-base-content/70"
        ]}>
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
