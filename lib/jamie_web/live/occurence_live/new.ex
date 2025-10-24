defmodule JamieWeb.OccurenceLive.New do
  use JamieWeb, :live_view

  alias Jamie.Occurences.Occurence

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8">
        <div class="max-w-3xl mx-auto">
          <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl p-6 sm:p-8 border border-base-300">
            <.live_component
              module={JamieWeb.OccurenceLive.FormComponent}
              id={:new}
              title="Create New Event"
              action={:new}
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :occurence, %Occurence{})}
  end

  def handle_info({JamieWeb.OccurenceLive.FormComponent, {:saved, _occurence}}, socket) do
    {:noreply, socket}
  end
end
