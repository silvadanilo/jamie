defmodule JamieWeb.UserSettingsLive do
  use JamieWeb, :live_view

  alias Jamie.Accounts

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="min-h-screen px-4 py-6 sm:py-8">
        <div class="max-w-2xl mx-auto">
          <div class="bg-base-100/80 backdrop-blur-sm rounded-3xl shadow-2xl p-6 sm:p-8 border border-base-300">
            <.header class="text-center mb-6 sm:mb-8">
              <h1 class="text-2xl sm:text-3xl md:text-4xl font-bold">Account Settings</h1>
              <:subtitle>
                <div class="mt-2 text-base sm:text-lg text-base-content/70">
                  Manage your account profile
                </div>
              </:subtitle>
            </.header>

            <div class="space-y-8 sm:space-y-12">
              <div>
                <.simple_form
                  for={@profile_form}
                  id="profile_form"
                  phx-submit="update_profile"
                  phx-change="validate_profile"
                >
                  <.input
                    field={@profile_form[:name]}
                    type="text"
                    label="Name"
                    autocomplete="given-name"
                    phx-debounce="blur"
                  />
                  <.input
                    field={@profile_form[:surname]}
                    type="text"
                    label="Surname"
                    autocomplete="family-name"
                    phx-debounce="blur"
                  />
                  <.input
                    field={@profile_form[:phone]}
                    type="tel"
                    label="Phone"
                    autocomplete="tel"
                    inputmode="tel"
                    phx-debounce="blur"
                  />
                  <.input
                    field={@profile_form[:preferred_role]}
                    type="select"
                    label="I prefer to play as"
                    options={[{"Base", "base"}, {"Flyer", "flyer"}]}
                  />
                  <:actions>
                    <.button
                      phx-disable-with="Saving..."
                      class="w-full sm:w-auto min-h-14 text-base sm:text-lg"
                      variant="primary"
                    >
                      Save Profile
                    </.button>
                  </:actions>
                </.simple_form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

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
