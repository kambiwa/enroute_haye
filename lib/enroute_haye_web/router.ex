defmodule EnrouteHayeWeb.Router do
  use EnrouteHayeWeb, :router

  import EnrouteHayeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EnrouteHayeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EnrouteHayeWeb do
    pipe_through :browser

    live "/", Unauth.Home, :index
    live "/journey", Unauth.Journey, :index
    live "/audio", Auth.Audio.Index, :index
    live "/uploads", Auth.Uploads.Audio, :index
    get "/pdf/itinerary/:token", PDFController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", EnrouteHayeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:enroute_haye, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EnrouteHayeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/admin", EnrouteHayeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{EnrouteHayeWeb.UserAuth, :require_authenticated}] do

      live "/dashboard", Auth.Admin.Dashboard, :index


      live "/accomodations", Auth.Accommodations.Index, :index
      live "/accomodations/new", Auth.Accommodations.New, :new
      live "/accomodations/:id/edit", Auth.Accommodations.Edit, :edit

      live "/events", Auth.Events.Index, :index
      live "/events/new", Auth.Events.New, :new
      live "/events/:id/edit", Auth.Events.Edit, :edit

      live "/foods", Auth.Foods.Index, :index
      live "/foods/new", Auth.Foods.New, :new
      live "/foods/:id/edit", Auth.Foods.Edit, :edit

      live "/audio", Auth.AudioManager.Index, :index
      live "/audio/new", Auth.AudioManager.New, :new
      live "/audio/:id/edit", Auth.AudioManager.Edit, :edit

      live "/media", Auth.MediaManager.Index, :index
      live "/media/new", Auth.MediaManager.New, :new
      live "/media/:id/edit", Auth.MediaManager.Edit, :edit


      live "/trips", Auth.Trips.Index, :index
      live "/trips/new", Auth.Trips.New, :new
      live "/trips/:id/edit", Auth.Trips.Edit, :edit



      live "/sites", Auth.Sites.Index, :index
      live "/sites/new", Auth.Sites.New, :new
      live "/sites/:id/edit", Auth.Sites.Edit, :edit


      live "/trips", Auth.Trips.Index, :index
      live "/trips/new", Auth.Trips.New, :new
      live "/trips/:id/edit", Auth.Trips.Edit, :edit


      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", EnrouteHayeWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{EnrouteHayeWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
