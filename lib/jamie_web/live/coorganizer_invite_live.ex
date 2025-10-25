defmodule JamieWeb.CoorganizerInviteLive do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen flex items-center justify-center px-4 py-6">
        <div class="max-w-md w-full">
          <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl p-6 sm:p-8 border border-base-300">
            <%= if @coorganizer && @occurence do %>
              <div class="text-center space-y-6">
                <div>
                  <h1 class="text-2xl font-bold mb-2">Co-organizer Invitation</h1>
                  <p class="text-base-content/70">
                    You've been invited to co-organize:
                  </p>
                </div>

                <div class="bg-base-200 rounded-lg p-4 text-left">
                  <h2 class="font-semibold text-lg mb-2">{@occurence.title}</h2>
                  <p class="text-sm text-base-content/70">
                    {Calendar.strftime(@occurence.date, "%B %d, %Y at %I:%M %p")}
                  </p>
                  <p :if={@occurence.location} class="text-sm text-base-content/70 mt-1">
                    {@occurence.location}
                  </p>
                </div>

                <%= if @token_valid do %>
                  <%= if @current_user do %>
                    <div class="space-y-4">
                      <p class="text-sm">
                        Click below to accept the invitation and become a co-organizer.
                      </p>
                      <.button
                        phx-click="accept"
                        class="w-full"
                        variant="primary"
                      >
                        Accept Invitation
                      </.button>
                    </div>
                  <% else %>
                    <div class="space-y-4">
                      <p class="text-sm">
                        Please log in or create an account to accept this invitation.
                      </p>
                      <.button
                        navigate={~p"/login?#{%{return_to: "/coorganizer-invite/#{@token}"}}"}
                        class="w-full"
                        variant="primary"
                      >
                        Log In / Sign Up
                      </.button>
                    </div>
                  <% end %>
                <% else %>
                  <div class="alert alert-error">
                    <.icon name="hero-exclamation-circle" class="size-5" />
                    <span>This invitation has expired</span>
                  </div>
                <% end %>
              </div>
            <% else %>
              <div class="text-center">
                <div class="alert alert-error">
                  <.icon name="hero-exclamation-circle" class="size-5" />
                  <span>Invalid or expired invitation link</span>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    coorganizer = Occurences.get_coorganizer_by_token(token)

    socket =
      Phoenix.Component.assign_new(socket, :current_path, fn ->
        "/coorganizer-invite/#{token}"
      end)

    case coorganizer do
      nil ->
        {:ok,
         socket
         |> assign(:coorganizer, nil)
         |> assign(:occurence, nil)
         |> assign(:token_valid, false)
         |> assign(:token, token)}

      coorganizer ->
        occurence = Occurences.get_occurence!(coorganizer.occurence_id)
        token_valid = Occurences.Coorganizer.token_valid?(coorganizer)

        # If user is not logged in and token is valid, store return path
        socket =
          if !socket.assigns.current_user && token_valid do
            Phoenix.LiveView.put_flash(
              socket,
              :info,
              "Please log in or create an account to accept this invitation."
            )
          else
            socket
          end

        {:ok,
         socket
         |> assign(:coorganizer, coorganizer)
         |> assign(:occurence, occurence)
         |> assign(:token_valid, token_valid)
         |> assign(:token, token)}
    end
  end

  def handle_event("accept", _params, socket) do
    case Occurences.accept_coorganizer_invitation(
           socket.assigns.coorganizer,
           socket.assigns.current_user.id
         ) do
      {:ok, _coorganizer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation accepted! You are now a co-organizer.")
         |> push_navigate(to: ~p"/occurences")}

      {:error, :token_expired} ->
        {:noreply,
         socket
         |> put_flash(:error, "This invitation has expired")
         |> assign(:token_valid, false)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to accept invitation")}
    end
  end
end
