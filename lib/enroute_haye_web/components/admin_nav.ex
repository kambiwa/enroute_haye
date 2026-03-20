defmodule EnrouteHayeWeb.AdminNav do
  @moduledoc """
  Provides an `on_mount` hook that sets `current_page` in the socket assigns
  so the admin sidebar can highlight the active link automatically.

  ## Usage

  In any admin LiveView:

      use EnrouteHayeWeb, :live_view

      on_mount {EnrouteHayeWeb.AdminNav, :dashboard}   # or :sites, :bookings, etc.

  Or via the router for a whole scope:

      live_session :admin,
        on_mount: [
          EnrouteHayeWeb.AdminAuth,          # your existing auth guard
          {EnrouteHayeWeb.AdminNav, :infer}  # auto-infer from route
        ]

  When using `:infer`, the hook reads the LiveView module name to pick the atom.
  For explicit control, pass the atom directly.

  ## Supported page atoms

    :dashboard | :sites | :events | :foods | :audio | :media |
    :trips | :accommodations | :bookings | :reviews | :users | :settings
  """

  import Phoenix.LiveView

  @doc false
  def on_mount(page, _params, _session, socket) when is_atom(page) and page != :infer do
    {:cont, assign(socket, :current_page, page)}
  end

  def on_mount(:infer, _params, _session, socket) do
    page =
      socket
      |> Phoenix.LiveView.get_connect_info(:peer_data)
      |> infer_page_from_view(socket.view)

    {:cont, assign(socket, :current_page, page)}
  end

  # Infer from the LiveView module name as a fallback
  defp infer_page_from_view(_peer_data, view) do
    view
    |> Module.split()
    |> List.last()
    |> String.downcase()
    |> then(fn name ->
      cond do
        String.contains?(name, "dashboard")     -> :dashboard
        String.contains?(name, "site")          -> :sites
        String.contains?(name, "event")         -> :events
        String.contains?(name, "food")          -> :foods
        String.contains?(name, "audio")         -> :audio
        String.contains?(name, "media")         -> :media
        String.contains?(name, "trip")          -> :trips
        String.contains?(name, "accommodation") -> :accommodations
        String.contains?(name, "booking")       -> :bookings
        String.contains?(name, "review")        -> :reviews
        String.contains?(name, "user")          -> :users
        String.contains?(name, "setting")       -> :settings
        true                                    -> :dashboard
      end
    end)
  end


  defp assign(socket, key, value) do
    Phoenix.LiveView.assign(socket, key, value)
  end
end
