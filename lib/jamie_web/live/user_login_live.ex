defmodule JamieWeb.UserLoginLive do
  use JamieWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={assigns[:current_user]}>
      <div class="min-h-screen flex flex-col justify-center py-6 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md mx-auto">
          <.header class="text-center mb-8 sm:mb-10">
            <div class="text-2xl sm:text-3xl font-bold">Sign in to account</div>
            <:subtitle>
              <span class="block mt-3 text-base sm:text-sm">
                Don't have an account?
                <.link
                  navigate={if @return_to, do: ~p"/register?#{%{return_to: @return_to}}", else: ~p"/register"}
                  class="font-semibold text-primary hover:text-primary-focus underline"
                >
                  Sign up
                </.link>
              </span>
            </:subtitle>
          </.header>

          <div class="bg-base-200/50 backdrop-blur-sm rounded-2xl shadow-xl p-6 sm:p-8 space-y-6">
            <div :if={@error_message} class="alert alert-error shadow-lg">
              <.icon name="hero-exclamation-circle" class="h-5 w-5" />
              <span>{@error_message}</span>
            </div>
            <.simple_form
              for={@form}
              id="login_form"
              phx-submit="login"
              phx-change="validate"
              phx-trigger-action={@trigger_submit}
              action={if @return_to, do: ~p"/login?#{%{return_to: @return_to}}", else: ~p"/login"}
              method="post"
            >
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                required
                placeholder="you@example.com"
                autocomplete="email"
                inputmode="email"
              />
              <.input
                field={@form[:password]}
                type="password"
                label="Password"
                placeholder="••••••••"
                autocomplete="current-password"
              />

              <:actions>
                <div class="flex items-center justify-between w-full">
                  <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
                </div>
              </:actions>
              <:actions>
                <.button
                  phx-disable-with="Signing in..."
                  class="w-full min-h-[56px] text-base sm:text-lg"
                >
                  <span class="flex items-center justify-center">
                    Sign in <.icon name="hero-arrow-right" class="h-5 w-5 ml-2" />
                  </span>
                </.button>
              </:actions>
            </.simple_form>

            <div class="relative py-4">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-base-300"></div>
              </div>
              <div class="relative flex justify-center text-sm">
                <span class="bg-base-200/50 px-4 text-base-content/60 font-medium">
                  Or continue with
                </span>
              </div>
            </div>

            <.button phx-click="send_magic_link" variant="secondary" class="w-full min-h-[56px]">
              <span class="flex items-center justify-center text-base">
                <.icon name="hero-envelope" class="h-5 w-5 mr-2" /> Send me a magic link ✨
              </span>
            </.button>
          </div>

          <p class="mt-6 text-center text-sm text-base-content/60 px-4">
            By continuing, you agree to our Terms of Service and Privacy Policy
          </p>
        </div>
      </div>
    </Layouts.app>
    """
  end

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
