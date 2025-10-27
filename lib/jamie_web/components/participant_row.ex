defmodule JamieWeb.ParticipantRow do
  @moduledoc """
  A reusable participant row component for displaying participant information in tables.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  attr :participant, :map, required: true, doc: "The participant data"
  attr :index, :integer, doc: "The position/index for waitlist participants"
  attr :show_position, :boolean, default: false, doc: "Whether to show position number"
  attr :actions, :list, default: [], doc: "List of action button configurations"
  attr :variant, :string, default: "default", values: ["default", "cancelled"], doc: "The row variant"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  defp display_name(participant) do
    cond do
      participant.name ->
        if participant.surname, do: "#{participant.name} #{participant.surname}", else: participant.name

      participant.user ->
        if participant.user.surname,
          do: "#{participant.user.name} #{participant.user.surname}",
          else: participant.user.name

      true ->
        "Unknown"
    end
  end

  defp display_phone(participant) do
    cond do
      participant.phone -> participant.phone
      participant.user && participant.user.phone -> participant.user.phone
      true -> "—"
    end
  end

  def participant_row(assigns) do
    assigns = assign(assigns, :display_name, display_name(assigns.participant))
    assigns = assign(assigns, :display_phone, display_phone(assigns.participant))

    ~H"""
    <div class={[
      "px-4 py-4 md:px-6 hover:bg-base-200 dark:hover:bg-slate-700/20 transition-colors",
      "odd:bg-base-100 dark:odd:bg-slate-800/30 even:bg-base-200/50 dark:even:bg-slate-700/20",
      @class
    ]}>
      <!-- Mobile Layout -->
      <div class="md:hidden space-y-3">
        <div class="flex justify-between items-start">
          <div>
            <div :if={@show_position} class="flex items-center gap-2 mb-1">
              <span class="text-orange-500 font-bold text-lg">#{@index}</span>
              <p class={[
                "font-semibold text-lg",
                @variant == "cancelled" && "text-base-content/70 dark:text-slate-400"
              ]}>
                {@display_name}
              </p>
            </div>
            <p
              :if={!@show_position}
              class={[
                "font-semibold text-lg",
                @variant == "cancelled" && "text-base-content/70 dark:text-slate-400"
              ]}
            >
              {@participant.user.name} {@participant.user.surname}
            </p>
            <p class={[
              "text-sm mt-1",
              @variant == "cancelled" && "text-base-content/60 dark:text-slate-500",
              @variant != "cancelled" && "text-base-content/70 dark:text-slate-400"
            ]}>
              {@display_phone}
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
                  action[:color] == "indigo" && "border-indigo-500/50 text-indigo-400 hover:bg-indigo-500/10",
                  (action[:full_width] || false) && "w-full flex items-center justify-center gap-2"
                ]}
              >
                <.icon name={action[:icon]} class="h-5 w-5" />
                {if action[:label], do: action[:label], else: ""}
              </button>
            <% end %>
          </div>
        </div>
        <div class="flex items-center gap-4 mb-3">
          <span class={[
            "px-3 py-1 text-sm rounded-lg font-medium",
            @variant == "cancelled" && "bg-base-200 dark:bg-slate-700 border border-sky-500/30 text-sky-400",
            @variant != "cancelled" && "bg-sky-500 text-white"
          ]}>
            {String.capitalize(@participant.role)}
          </span>
          <span class={[
            "text-sm",
            @variant == "cancelled" && "text-base-content/80 dark:text-slate-400",
            @variant != "cancelled" && "text-base-content/70 dark:text-slate-400"
          ]}>
            <%= if @variant == "cancelled" do %>
              Cancelled {Calendar.strftime(@participant.cancelled_at, "%b %d, %H:%M")}
            <% else %>
              {Calendar.strftime(@participant.registered_at || @participant.inserted_at, "%b %d, %H:%M")}
            <% end %>
          </span>
        </div>
      </div>
      
    <!-- Desktop Layout -->
      <div class="hidden md:grid gap-4 items-center" style={grid_columns(@show_position)}>
        <div :if={@show_position} class="text-orange-500 font-bold text-xl">#{@index}</div>
        <div class={[
          "font-semibold text-lg",
          @variant == "cancelled" && "text-base-content/70 dark:text-slate-400"
        ]}>
          {@participant.user.name} {@participant.user.surname}
        </div>
        <div class={[
          @variant == "cancelled" && "text-base-content/60 dark:text-slate-500",
          @variant != "cancelled" && "text-base-content/80 dark:text-slate-300"
        ]}>
          {@participant.user.phone || "—"}
        </div>
        <div>
          <span class={[
            "px-3 py-1 text-sm rounded-lg font-medium",
            @variant == "cancelled" && "bg-base-200 dark:bg-slate-700 border border-sky-500/30 text-sky-400",
            @variant != "cancelled" && "bg-sky-500 text-white"
          ]}>
            {String.capitalize(@participant.role)}
          </span>
        </div>
        <div class={[
          @variant == "cancelled" && "text-base-content/80 dark:text-slate-400",
          @variant != "cancelled" && "text-base-content/80 dark:text-slate-300"
        ]}>
          <%= if @variant == "cancelled" do %>
            Cancelled {Calendar.strftime(@participant.updated_at, "%b %d, %H:%M")}
          <% else %>
            {Calendar.strftime(@participant.registered_at || @participant.inserted_at, "%b %d, %H:%M")}
          <% end %>
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

  defp grid_columns(show_position) do
    if show_position do
      "grid-cols-[auto_2fr_1.5fr_1fr_1.5fr_1fr]"
    else
      "grid-cols-[2fr_1.5fr_1fr_1.5fr_1fr]"
    end
  end
end
