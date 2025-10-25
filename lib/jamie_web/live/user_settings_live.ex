defmodule JamieWeb.UserSettingsLive do
  use JamieWeb, :live_view

  alias Jamie.Accounts

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profile_changeset = Accounts.change_user_profile(user)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:profile_form, to_form(profile_changeset))

    {:ok, socket}
  end

  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params

    profile_form =
      socket.assigns.current_user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_profile(user, user_params) do
      {:ok, _user} ->
        info = "Profile updated successfully"

        {:noreply,
         socket
         |> put_flash(:info, info)
         |> assign(profile_form: to_form(Accounts.change_user_profile(user)))}

      {:error, changeset} ->
        {:noreply, assign(socket, :profile_form, to_form(changeset))}
    end
  end
end
