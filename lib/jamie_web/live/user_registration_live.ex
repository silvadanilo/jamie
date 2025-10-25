defmodule JamieWeb.UserRegistrationLive do
  use JamieWeb, :live_view

  alias Jamie.Accounts
  alias Jamie.Accounts.User

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={assigns[:current_user]}>
      <div class="min-h-screen flex flex-col px-4 py-6 sm:py-8">
        <div class="flex-1 flex items-center justify-center">
          <div class="w-full max-w-md">
            <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl p-6 sm:p-8 border border-base-300">
              <.header class="text-center mb-6 sm:mb-8">
                <h1 class="text-2xl sm:text-3xl md:text-4xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                  Join Jamie
                </h1>
                <:subtitle>
                  <div class="mt-3 text-base sm:text-lg text-base-content/70">
                    Already registered?
                    <.link
                      navigate={if @return_to, do: ~p"/login?#{%{return_to: @return_to}}", else: ~p"/login"}
                      class="font-semibold text-primary hover:text-primary-focus underline underline-offset-2"
                    >
                      Sign in
                    </.link>
                  </div>
                </:subtitle>
              </.header>

              <.simple_form
                for={@form}
                id="registration_form"
                phx-submit="save"
                phx-change="validate"
                phx-trigger-action={@trigger_submit}
                action={
                  if @return_to,
                    do: ~p"/login?#{%{_action: "registered", return_to: @return_to}}",
                    else: ~p"/login?_action=registered"
                }
                method="post"
              >
                <.error :if={@check_errors}>
                  Oops, something went wrong! Please check the errors below.
                </.error>

                <.input
                  field={@form[:email]}
                  type="email"
                  label="Email"
                  required
                  autocomplete="email"
                  inputmode="email"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:name]}
                  type="text"
                  label="Name"
                  autocomplete="given-name"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:surname]}
                  type="text"
                  label="Surname"
                  autocomplete="family-name"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:phone]}
                  type="tel"
                  label="Phone"
                  autocomplete="tel"
                  inputmode="tel"
                  phx-debounce="blur"
                />

                <.input
                  field={@form[:preferred_role]}
                  type="select"
                  label="I prefer to play as"
                  options={[{"Base", "base"}, {"Flyer", "flyer"}]}
                />

                <:actions>
                  <.button
                    phx-disable-with="Creating account..."
                    class="w-full text-base sm:text-lg min-h-14"
                    variant="primary"
                  >
                    Create an account <.icon name="hero-arrow-right" class="h-5 w-5 ml-2" />
                  </.button>
                </:actions>
              </.simple_form>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    return_to = params["return_to"]

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false, return_to: return_to)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_magic_link(
            user,
            &url(~p"/users/magic-link/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
