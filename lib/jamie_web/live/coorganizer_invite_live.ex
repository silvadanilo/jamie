defmodule JamieWeb.CoorganizerInviteLive do
  use JamieWeb, :live_view

  alias Jamie.Occurences

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
         |> push_navigate(to: ~p"/organizer/occurences")}

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
