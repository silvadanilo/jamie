defmodule JamieWeb.TableWaitlistRow do
  @moduledoc """
  A waitlist participant row component specifically designed for table layouts.
  """
  use Phoenix.Component
  import JamieWeb.CoreComponents

  attr :participant, :map, required: true, doc: "The participant data"
  attr :index, :integer, required: true, doc: "The position in the waitlist"
  attr :actions, :list, default: [], doc: "List of action button configurations"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :editing_role, :boolean, default: false, doc: "Whether the role is being edited"
  attr :on_start_edit_role, :string, default: nil, doc: "Event to start editing role"
  attr :on_cancel_edit_role, :string, default: nil, doc: "Event to cancel editing role"

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
                {display_name(@participant)}
              </p>
            </div>
            <p class="text-base-content/70 text-sm">{display_contact(@participant)}</p>
          </div>
        </div>
        <div class="flex items-center gap-4 mb-3">
          <%= if @editing_role do %>
            <div class="flex items-center gap-2">
              <form phx-submit="update_role" class="flex items-center gap-2">
                <input type="hidden" name="participant_id" value={@participant.id} />
                <select
                  name="role"
                  class="px-3 py-1 text-sm rounded-lg border border-base-300 bg-base-100 text-base-content"
                >
                  <option value="base" selected={@participant.role == "base"}>Base</option>
                  <option value="flyer" selected={@participant.role == "flyer"}>Flyer</option>
                </select>
                <button
                  type="submit"
                  class="p-1 rounded-lg hover:bg-base-200 transition-colors"
                  title="Save"
                >
                  <.icon name="hero-check" class="h-4 w-4 text-base-content/70" />
                </button>
              </form>
              <button
                type="button"
                phx-click={@on_cancel_edit_role}
                class="p-1 rounded-lg hover:bg-base-200 transition-colors"
                title="Cancel"
              >
                <.icon name="hero-x-mark" class="h-4 w-4 text-base-content/70" />
              </button>
            </div>
          <% else %>
            <div class="flex items-center gap-2">
              <span class={[
                "px-3 py-1 text-sm rounded-lg font-medium",
                @participant.role == "base" && "bg-blue-500 text-white",
                @participant.role == "flyer" && "bg-orange-500 text-white"
              ]}>
                {String.capitalize(@participant.role)}
              </span>
              <%= if @on_start_edit_role do %>
                <button
                  type="button"
                  phx-click={@on_start_edit_role}
                  phx-value-id={@participant.id}
                  class="p-1 rounded-lg hover:bg-base-200 transition-colors"
                  title="Edit role"
                >
                  <.icon name="hero-pencil" class="h-4 w-4 text-base-content/70" />
                </button>
              <% end %>
            </div>
          <% end %>
          <span class="text-base-content/70 text-sm">
            {Calendar.strftime(@participant.registered_at || @participant.inserted_at, "%b %d, %H:%M")}
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
          {display_name(@participant)}
        </div>
        <div class="text-base-content/70">{display_contact(@participant)}</div>
        <div>
          <%= if @editing_role do %>
            <div class="flex items-center gap-2">
              <form phx-submit="update_role" class="flex items-center gap-2">
                <input type="hidden" name="participant_id" value={@participant.id} />
                <select
                  name="role"
                  class="px-3 py-1 text-sm rounded-lg border border-base-300 bg-base-100 text-base-content"
                >
                  <option value="base" selected={@participant.role == "base"}>Base</option>
                  <option value="flyer" selected={@participant.role == "flyer"}>Flyer</option>
                </select>
                <button
                  type="submit"
                  class="p-1 rounded-lg hover:bg-base-200 transition-colors"
                  title="Save"
                >
                  <.icon name="hero-check" class="h-4 w-4 text-base-content/70" />
                </button>
              </form>
              <button
                type="button"
                phx-click={@on_cancel_edit_role}
                class="p-1 rounded-lg hover:bg-base-200 transition-colors"
                title="Cancel"
              >
                <.icon name="hero-x-mark" class="h-4 w-4 text-base-content/70" />
              </button>
            </div>
          <% else %>
            <div class="flex items-center gap-2">
              <span class={[
                "px-3 py-1 text-sm rounded-lg font-medium",
                @participant.role == "base" && "bg-blue-500 text-white",
                @participant.role == "flyer" && "bg-orange-500 text-white"
              ]}>
                {String.capitalize(@participant.role)}
              </span>
              <%= if @on_start_edit_role do %>
                <button
                  type="button"
                  phx-click={@on_start_edit_role}
                  phx-value-id={@participant.id}
                  class="p-1 rounded-lg hover:bg-base-200 transition-colors"
                  title="Edit role"
                >
                  <.icon name="hero-pencil" class="h-4 w-4 text-base-content/70" />
                </button>
              <% end %>
            </div>
          <% end %>
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

  defp display_contact(participant) do
    cond do
      participant.phone -> participant.phone
      participant.email -> participant.email
      participant.user && participant.user.phone -> participant.user.phone
      participant.user && participant.user.email -> participant.user.email
      true -> "—"
    end
  end
end
