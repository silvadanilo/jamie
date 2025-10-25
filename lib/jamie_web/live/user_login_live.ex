defmodule JamieWeb.UserLoginLive do
  use JamieWeb, :live_view

  def mount(params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    error_message = Phoenix.Flash.get(socket.assigns.flash, :error)
    form = to_form(%{"email" => email, "password" => "", "remember_me" => "false"}, as: "user")

    # Store return_to in socket assigns for later use
    return_to = params["return_to"]

    {:ok,
     assign(socket,
       form: form,
       error_message: error_message,
       trigger_submit: false,
       return_to: return_to
     )}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    form = to_form(user_params, as: "user")
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("login", %{"user" => user_params}, socket) do
    %{"email" => email, "password" => password} = user_params

    if email == "" or password == "" do
      {:noreply,
       socket
       |> assign(:error_message, "Email and password are required")
       |> assign(:form, to_form(user_params, as: "user"))}
    else
      case Jamie.Accounts.get_user_by_email_and_password(email, password) do
        nil ->
          {:noreply,
           socket
           |> assign(:error_message, "Invalid email or password")
           |> assign(:form, to_form(user_params, as: "user"))}

        _user ->
          {:noreply,
           socket
           |> assign(:trigger_submit, true)
           |> assign(:form, to_form(user_params, as: "user"))}
      end
    end
  end

  def handle_event("send_magic_link", _params, socket) do
    email = get_in(socket.assigns.form.params, ["email"]) || ""

    if email != "" do
      if user = Jamie.Accounts.get_user_by_email(email) do
        Jamie.Accounts.deliver_user_magic_link(
          user,
          &url(~p"/users/magic-link/#{&1}")
        )
      end

      {:noreply,
       socket
       |> put_flash(
         :info,
         "If your email is in our system, you will receive a magic link shortly."
       )
       |> push_navigate(to: ~p"/login")}
    else
      {:noreply, assign(socket, :error_message, "Please enter your email address first.")}
    end
  end
end
