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
  attr :editing_role, :boolean, default: false, doc: "Whether the role is being edited"
  attr :on_start_edit_role, :string, default: nil, doc: "Event to start editing role"
  attr :on_cancel_edit_role, :string, default: nil, doc: "Event to cancel editing role"

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
                @variant == "cancelled" && "bg-base-200 border border-sky-500/30 text-sky-500",
                @variant != "cancelled" && "bg-sky-500 text-white"
              ]}>
                {String.capitalize(@participant.role)}
              </span>
              <%= if @on_start_edit_role && @variant != "cancelled" do %>
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
                @variant == "cancelled" && "bg-base-200 border border-sky-500/30 text-sky-500",
                @variant != "cancelled" && "bg-sky-500 text-white"
              ]}>
                {String.capitalize(@participant.role)}
              </span>
              <%= if @on_start_edit_role && @variant != "cancelled" do %>
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
