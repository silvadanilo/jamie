defmodule JamieWeb.OccurenceLive.Edit do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8">
        <div class="max-w-3xl mx-auto space-y-6">
          <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl p-6 sm:p-8 border border-base-300">
            <.live_component
              module={JamieWeb.OccurenceLive.FormComponent}
              id={@occurence.id}
              title="Edit Event"
              action={:edit}
              occurence={@occurence}
              current_user={@current_user}
              navigate={~p"/occurences"}
            />
          </div>

          <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl p-6 sm:p-8 border border-base-300">
            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-xl font-semibold">Co-organizers</h3>
                <p class="text-sm text-base-content/70 mt-1">Manage who can help organize this event</p>
              </div>
              <.link
                navigate={~p"/occurences/#{@occurence.id}/coorganizers"}
                class="btn btn-primary"
              >
                <.icon name="hero-users" class="h-5 w-5" /> Manage Co-organizers
              </.link>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      {:ok, assign(socket, :occurence, occurence)}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to edit this event")
        |> push_navigate(to: ~p"/occurences")

      {:ok, socket}
    end
  end

  def handle_info({JamieWeb.OccurenceLive.FormComponent, {:saved, _occurence}}, socket) do
    {:noreply, socket}
  end
end
