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

  pipeline :trip_guest_access do
    plug :ensure_trip_guest_access
  end

  scope "/", EnrouteHayeWeb do
    pipe_through :browser

    live "/", Unauth.LandingPage, :index
    live "/kuomboka", Unauth.Kuomboka, :index
    live "/mize", Unauth.Mize, :index
    live "/ncwala", Unauth.Ncwala, :index
    live "/bemba", Unauth.Bemba, :index
    live "/audio", Auth.Audio.Index, :index
    live "/uploads", Auth.Uploads.Audio, :index
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

  scope "/", EnrouteHayeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{EnrouteHayeWeb.UserAuth, :require_authenticated}] do
      live "/admin/dashboard", Auth.Admin.Dashboard, :index

      live "/admin/users", Auth.Admin.Users, :index
      live "/admin/department", Auth.Admin.Departments, :index
      live "/admin/jobs", Auth.Admin.Jobs, :index

      live "/admin/accomodations", Auth.Accommodations.Index, :index

      live "/admin/reviews", Auth.Review.Index, :index
      live "/admin/bookings", Auth.Bookings.Index, :index

      live "/admin/events", Auth.Events.Index, :index
      live "/admin/events/new", Auth.Events.Index, :new
      live "/admin/events/:id/edit", Auth.Events.Index, :edit

      live "/admin/foods", Auth.Foods.Index, :index
      live "/admin/foods/new", Auth.Foods.Index, :new
      live "/admin/foods/:id/edit", Auth.Foods.Index, :edit

      live "/admin/audio", Auth.AudioManager.Index, :index
      live "/admin/audio/new", Auth.AudioManager.Index, :new
      live "/admin/audio/:id/edit", Auth.AudioManager.Index, :edit

      live "/admin/media", Auth.MediaManager.Index, :index
      live "/admin/media/new", Auth.MediaManager.Index, :new
      live "/admin/media/:id/edit", Auth.MediaManager.Index, :edit

      live "/admin/trips", Auth.Trips.Index, :index

      live "/admin/sites", Auth.Sites.Index, :index
      live "/admin/sites/new", Auth.Sites.Index, :new
      live "/admin/sites/:id/edit", Auth.Sites.Index, :edit

      live "/admin/roads", Auth.Road.Index, :index
      live "/admin/roads/new", Auth.Road.Index, :new
      live "/admin/roads/:id/edit", Auth.Road.Index, :edit

      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", EnrouteHayeWeb do
    pipe_through [:browser, :trip_guest_access]

    live_session :current_user,
      on_mount: [{EnrouteHayeWeb.UserAuth, :mount_current_scope}] do
      live "/journey", Unauth.Journey, :index
      live "/journey/:trip_id", Unauth.Journey, :index
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
    get "/trips/:trip_id/itinerary.pdf", TripPDFController, :show
  end

  defp ensure_trip_guest_access(conn, _opts) do
    cookie_name = "_enroute_haye_trip_access"
    conn = Plug.Conn.fetch_cookies(conn, signed: [cookie_name])

    token = conn.cookies[cookie_name]

    token =
      if is_binary(token) and byte_size(token) >= 32,
        do: token,
        else: Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

    conn =
      if conn.cookies[cookie_name] == token do
        conn
      else
        Plug.Conn.put_resp_cookie(conn, cookie_name, token,
          sign: true,
          http_only: true,
          same_site: "Lax",
          max_age: 60 * 60 * 24 * 365,
          secure: conn.scheme == :https
        )
      end

    Plug.Conn.put_session(conn, :trip_guest_access, token)
  end
end
