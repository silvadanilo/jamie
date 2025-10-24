defmodule JamieWeb.OccurenceLive.Edit do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8">
        <div class="max-w-3xl mx-auto">
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
