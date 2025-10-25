defmodule JamieWeb.Router do
  use JamieWeb, :router

  import JamieWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {JamieWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JamieWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{JamieWeb.UserAuth, :mount_current_user}] do
      live "/", HomeLive, :index
      live "/events/:slug", OccurenceLive.Show, :show
    end
  end

  scope "/", JamieWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{JamieWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UserRegistrationLive, :new
      live "/login", UserLoginLive, :new
    end

    post "/login", UserSessionController, :create
  end

  scope "/", JamieWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{JamieWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit

      live "/occurences", OccurenceLive.Index, :index
      live "/occurences/new", OccurenceLive.New, :new
      live "/occurences/:id/edit", OccurenceLive.Edit, :edit
      live "/occurences/:id/coorganizers", OccurenceLive.Coorganizers, :index
      live "/occurences/:id/participants", OccurenceLive.Participants, :index
      live "/occurences/:id/participants/new", OccurenceLive.Participants, :new
      live "/events/:slug/register", OccurenceLive.Register, :register
    end
  end

  scope "/", JamieWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete
    get "/users/magic-link/:token", UserMagicLinkController, :show

    live_session :current_user,
      on_mount: [{JamieWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/coorganizer-invite/:token", CoorganizerInviteLive, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", JamieWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:jamie, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: JamieWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
