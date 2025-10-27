defmodule JamieWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use JamieWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar bg-base-100 shadow-md px-3 sm:px-6 lg:px-8 py-2 sm:py-4 sticky top-0 z-50 backdrop-blur-sm bg-base-100/80">
      <div class="flex-1">
        <.link navigate={~p"/"} class="flex items-center gap-2 sm:gap-3 hover:opacity-80 transition-opacity">
          <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-white font-bold text-base sm:text-xl">
            J
          </div>
          <span class="text-base sm:text-xl font-bold hidden sm:inline">Jamie</span>
        </.link>
      </div>
      <div class="flex-none">
        <ul class="flex items-center gap-1 sm:gap-2 md:gap-4">
          <li>
            <.theme_toggle />
          </li>
          <%= if @current_scope do %>
            <li class="hidden sm:block">
              <.link navigate={~p"/organizer/occurences"} class="btn btn-ghost btn-sm">
                <.icon name="hero-calendar" class="h-4 w-4" /> My Events
              </.link>
            </li>
            <li class="hidden lg:block">
              <.link navigate={~p"/users/my-partecipations"} class="btn btn-ghost btn-sm">
                <.icon name="hero-ticket" class="h-4 w-4" /> My Participations
              </.link>
            </li>
            <li class="hidden md:block">
              <.link href={~p"/logout"} method="delete" class="btn btn-ghost btn-sm">
                <.icon name="hero-arrow-right-on-rectangle" class="h-4 w-4" /> Logout
              </.link>
            </li>
            <li class="dropdown dropdown-end">
              <div tabindex="0" role="button" class="cursor-pointer">
                <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-primary text-primary-content flex items-center justify-center font-semibold text-sm sm:text-base">
                  {String.first(@current_scope.email) |> String.upcase()}
                </div>
              </div>
              <ul
                tabindex="0"
                class="dropdown-content menu bg-base-100 rounded-box z-[1] w-52 p-2 shadow-xl border border-base-300 mt-3"
              >
                <li class="menu-title">
                  <span class="text-xs truncate">{@current_scope.email}</span>
                </li>
                <li class="sm:hidden">
                  <.link navigate={~p"/organizer/occurences"}>
                    <.icon name="hero-calendar" class="h-4 w-4" /> My Events
                  </.link>
                </li>
                <li>
                  <.link navigate={~p"/users/my-partecipations"}>
                    <.icon name="hero-ticket" class="h-4 w-4" /> My Participations
                  </.link>
                </li>
                <li>
                  <.link navigate={~p"/users/settings"}>
                    <.icon name="hero-cog-6-tooth" class="h-4 w-4" /> Settings
                  </.link>
                </li>
                <li>
                  <.link href={~p"/logout"} method="delete">
                    <.icon name="hero-arrow-right-on-rectangle" class="h-4 w-4" /> Logout
                  </.link>
                </li>
              </ul>
            </li>
          <% else %>
            <li>
              <.link navigate={~p"/login"} class="btn btn-ghost btn-sm">
                Sign In
              </.link>
            </li>
            <li>
              <.link navigate={~p"/register"} class="btn btn-primary btn-sm">
                Get Started
              </.link>
            </li>
          <% end %>
        </ul>
      </div>
    </header>

    <main>
      {render_slot(@inner_block)}
    </main>

    <footer class="footer footer-center p-4 sm:p-10 bg-base-200 text-base-content mt-auto">
      <aside>
        <div class="w-10 h-10 sm:w-12 sm:h-12 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-white font-bold text-lg sm:text-2xl mb-2 sm:mb-4">
          J
        </div>
        <p class="font-bold text-sm sm:text-base">
          Jamie - Your Jam Session Platform
        </p>
        <p class="text-xs sm:text-base">Copyright © {DateTime.utc_now().year} - All rights reserved</p>
      </aside>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
