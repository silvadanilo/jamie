defmodule JamieWeb.OccurenceLive.CoorganizersComponent do
  use JamieWeb, :live_component

  alias Jamie.Occurences
  alias Jamie.Repo

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        Co-organizers
        <:subtitle>Manage who can help organize this event</:subtitle>
      </.header>

      <div class="card bg-base-200 shadow-md">
        <div class="card-body">
          <h3 class="card-title text-base">Invite Co-organizer</h3>
          <.simple_form
            for={@invite_form}
            id="invite-coorganizer-form"
            phx-target={@myself}
            phx-submit="invite"
          >
            <.input
              field={@invite_form[:email]}
              type="email"
              label="Email Address"
              placeholder="coorganizer@example.com"
              required
            />
            <:actions>
              <.button
                phx-disable-with="Sending..."
                class="w-full sm:w-auto"
                variant="primary"
              >
                Send Invitation
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>

      <div :if={@non_creator_coorganizers != []} class="space-y-4">
        <h3 class="text-lg font-semibold">Current Co-organizers</h3>
        <div class="space-y-2">
          <div
            :for={coorg <- @non_creator_coorganizers}
            class="flex items-center justify-between p-4 bg-base-200 rounded-lg"
          >
            <div class="flex-1">
              <p class="font-medium">{coorg.invited_email}</p>
              <p class="text-sm text-base-content/70">
                <%= cond do %>
                  <% coorg.accepted_at -> %>
                    Accepted on {Calendar.strftime(coorg.accepted_at, "%B %d, %Y")}
                  <% coorg.invite_token && Occurences.Coorganizer.token_valid?(coorg) -> %>
                    Invitation pending (expires {Calendar.strftime(
                      coorg.invite_token_expires_at,
                      "%B %d, %Y at %H:%M"
                    )})
                  <% coorg.invite_token -> %>
                    Invitation expired
                  <% true -> %>
                    Status unknown
                <% end %>
              </p>
            </div>
            <button
              type="button"
              phx-click="remove"
              phx-value-id={coorg.id}
              phx-target={@myself}
              data-confirm="Are you sure you want to remove this co-organizer?"
              class="btn btn-sm btn-error"
            >
              Remove
            </button>
          </div>
        </div>
      </div>

      <div :if={@non_creator_coorganizers == []} class="text-center py-8 text-base-content/70">
        No co-organizers yet. Invite someone to help organize this event!
      </div>
    </div>
    """
  end

  def update(%{occurence: occurence} = assigns, socket) do
    coorganizers = Occurences.list_coorganizers(occurence.id)
    # Filter out the creator from the list
    non_creator_coorganizers = Enum.reject(coorganizers, & &1.is_creator)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:coorganizers, coorganizers)
     |> assign(:non_creator_coorganizers, non_creator_coorganizers)
     |> assign(:invite_form, to_form(%{"email" => ""}, as: :invite))}
  end

  def handle_event("invite", %{"invite" => %{"email" => email}}, socket) do
    case Occurences.invite_coorganizer(
           socket.assigns.occurence.id,
           email,
           socket.assigns.current_user
         ) do
      {:ok, _coorganizer} ->
        coorganizers = Occurences.list_coorganizers(socket.assigns.occurence.id)
        non_creator_coorganizers = Enum.reject(coorganizers, & &1.is_creator)

        {:noreply,
         socket
         |> assign(:coorganizers, coorganizers)
         |> assign(:non_creator_coorganizers, non_creator_coorganizers)
         |> assign(:invite_form, to_form(%{"email" => ""}, as: :invite))
         |> put_flash(:info, "Co-organizer invitation sent successfully")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:invite_form, to_form(changeset, as: :invite))
         |> put_flash(:error, "Failed to send invitation")}
    end
  end

  def handle_event("remove", %{"id" => id}, socket) do
    coorganizer = Occurences.get_coorganizer_by_token(id) || Repo.get!(Occurences.Coorganizer, id)

    # Prevent removal of the creator
    if coorganizer.is_creator do
      {:noreply, put_flash(socket, :error, "Cannot remove the event creator")}
    else
      case Occurences.remove_coorganizer(coorganizer) do
        {:ok, _} ->
          coorganizers = Occurences.list_coorganizers(socket.assigns.occurence.id)
          non_creator_coorganizers = Enum.reject(coorganizers, & &1.is_creator)

          {:noreply,
           socket
           |> assign(:coorganizers, coorganizers)
           |> assign(:non_creator_coorganizers, non_creator_coorganizers)
           |> put_flash(:info, "Co-organizer removed")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to remove co-organizer")}
      end
    end
  end
end
