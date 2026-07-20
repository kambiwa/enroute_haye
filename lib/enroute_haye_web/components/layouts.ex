defmodule EnrouteHayeWeb.Layouts do
  @moduledoc """
  Layouts and shared UI components for EnrouteHaye.
  """
  use EnrouteHayeWeb, :html

  embed_templates "layouts/*"



  # ───────────────────────────────────────────────
  #  PUBLIC LAYOUT
  # ───────────────────────────────────────────────
  attr :flash,         :map,    required: true
  attr :current_scope, :map,    default: nil
  attr :mobile_menu_open, :boolean, default: false
  attr :current_page,  :atom,   default: nil
  attr :show_footer,   :boolean, default: true
  slot :inner_block, required: true

  def unauth_app(assigns) do
      ~H"""
      <div class="min-h-screen flex flex-col kuomboka-bg">
        <div class="enroute-landing">
          <header class="zm-glass-nav fixed top-0 inset-x-0 z-50 transition-colors">
            <nav class="mx-auto max-w-7xl px-6 lg:px-10 h-20 flex items-center justify-between">
              <%!-- LOGO --%>
              <a href={~p"/"} class="font-zm-display text-lg font-bold tracking-tight text-zm-ink flex items-center gap-2 flex-shrink-0">
                <span class="w-8 h-8 rounded-full bg-gradient-to-br from-zm-copper to-zm-terracotta flex items-center justify-center text-white text-sm">E</span>
                Enroute Home
              </a>

            <%!-- CENTER LINKS --%>
              <ul class="hidden lg:flex items-center gap-9 font-medium text-sm text-zm-body">
                <li><.nav_link href={~p"/#destinations"}   label="Destinations"   active={@current_page == :destinations} /></li>
                <li><.nav_link href={~p"/#expirience"}     label="Experiences"    active={@current_page == :experiences} /></li>
                <li>
                  <.nav_dropdown href={~p"/#ceremony"} label="Ceremony" active={@current_page == :ceremony}>
                    <:item href={~p"/mize"}>Mize . Luvale people</:item>
                    <:item href={~p"/kuomboka"}>Kuomboka . Lozi People</:item>
                    <:item href={~p"/ncwala"}>Ncwala . Ngoni People</:item>
                    <:item href={~p"/bemba"}>Ukusefya pa Ng'wena . Bemba People</:item>
                  </.nav_dropdown>
                </li>
                <li><.nav_link href={~p"/journey"} label="Plan Your Trip" active={@current_page == :journey} /></li>
              </ul>

              <%!-- RIGHT ACTIONS --%>
              <div class="hidden lg:flex items-center gap-4">
                <button aria-label="Search" class="w-10 h-10 rounded-full flex items-center justify-center hover:bg-zm-soft-gray transition-colors text-zm-body">
                  <svg viewBox="0 0 24 24" class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.8">
                    <circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>
                  </svg>
                </button>
                <a href={~p"/users/log-in"} class="zm-btn-secondary text-sm">Sign In</a>
                <a href={~p"/journey"} class="zm-btn-primary text-sm">Plan Trip</a>
              </div>

              <%!-- MOBILE HAMBURGER --%>
              <button
                aria-label="Toggle menu"
                phx-click="toggle_mobile_menu"
                class="lg:hidden w-10 h-10 flex items-center justify-center text-zm-ink"
              >
                <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path d="M4 6h16M4 12h16M4 18h16"/>
                </svg>
              </button>
            </nav>

            <%!-- MOBILE MENU PANEL --%>
            <div :if={@mobile_menu_open} class="lg:hidden zm-glass-card mx-4 mb-4 p-6 flex flex-col gap-4">
              <.nav_link href={~p"/#barge"} label="Destinations" active={@current_page == :destinations} />
              <.nav_link href="#" label="Experiences" active={@current_page == :experiences} />
              <.nav_link href={~p"/journey"} label="Plan Your Trip" active={@current_page == :journey} />
              <a href={~p"/users/log-in"} class="font-medium text-zm-ink">Sign In</a>
              <a href={~p"/journey"} class="zm-btn-primary text-center mt-2">Plan Trip</a>
            </div>
          </header>
        </div>

        <main class="flex-1 pt-20">
          <.flash_group flash={@flash} />
          {render_slot(@inner_block)}
        </main>

        <%!-- footer unchanged for now --%>
      </div>
      """
    end

  # ───────────────────────────────────────────────
  #  ADMIN LAYOUT
  # ───────────────────────────────────────────────
  attr :flash,         :map,    required: true
  attr :page_title,    :string, default: "Dashboard"
  attr :current_page,  :atom,   default: :dashboard
  attr :current_scope, :map,    default: nil
  slot :inner_block, required: true

  def admin_app(assigns) do
    ~H"""
    <div class="drawer lg:drawer-open min-h-screen">
      <input id="admin-sidebar" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">

        <%!-- TOP BAR --%>
        <header style="position: sticky; top: 0; z-index: 30; display: flex; align-items: center; height: 64px; padding: 0 1.5rem; background: #ffffff; border-bottom: 1px solid #E8E2D9; box-shadow: 0 1px 4px rgba(0,0,0,0.06);">
          <label for="admin-sidebar" class="lg:hidden" aria-label="Open sidebar"
                 style="display: flex; align-items: center; justify-content: center; width: 36px; height: 36px; margin-right: 0.75rem; border-radius: 0.5rem; cursor: pointer; border: 1px solid #E8E2D9; color: #8B1A1A;">
            <.icon name="hero-bars-3" class="size-5" />
          </label>

          <div style="flex: 1;">
            <h1 style="font-size: 0.95rem; font-weight: 600; color: #1a1a1a; letter-spacing: 0.01em;">{@page_title}</h1>
          </div>

          <div style="display: flex; align-items: center; gap: 0.5rem;">
            <button aria-label="Notifications"
                    style="width: 36px; height: 36px; border-radius: 0.5rem; border: none; background: transparent; color: #9ca3af; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: background 0.15s, color 0.15s;"
                    onmouseover="this.style.background='rgba(139,26,26,0.06)'; this.style.color='#8B1A1A'"
                    onmouseout="this.style.background='transparent'; this.style.color='#9ca3af'">
              <.icon name="hero-bell" class="size-5" />
            </button>

            <div style="width: 1px; height: 24px; background: #E8E2D9; margin: 0 0.25rem;"></div>

            <%!-- USER DROPDOWN --%>
            <div class="dropdown dropdown-end">
              <label tabindex="0"
                     style="display: flex; align-items: center; gap: 0.6rem; cursor: pointer; padding: 0.35rem 0.6rem; border-radius: 0.5rem; transition: background 0.15s;"
                     onmouseover="this.style.background='#F9F7F4'"
                     onmouseout="this.style.background='transparent'">
                <div style="width: 32px; height: 32px; border-radius: 50%; background: #8B1A1A; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 0.75rem; font-weight: 700; flex-shrink: 0;">A</div>
                <div class="hidden sm:block" style="text-align: left; line-height: 1.3;">
                  <p style="font-size: 0.82rem; font-weight: 600; color: #1a1a1a;">Admin</p>
                  <p style="font-size: 0.68rem; color: #9ca3af;">Administrator</p>
                </div>
                <.icon name="hero-chevron-down" class="size-3.5 hidden sm:block" style="color: #9ca3af;" />
              </label>
              <ul tabindex="0" class="dropdown-content"
                  style="z-index: 50; margin-top: 0.5rem; width: 224px; background: #fff; border-radius: 0.75rem; box-shadow: 0 8px 24px rgba(0,0,0,0.1); border: 1px solid #E8E2D9; padding: 0.375rem; font-size: 0.85rem; list-style: none;">
                <li style="padding: 0.6rem 0.75rem; border-bottom: 1px solid #E8E2D9; margin-bottom: 0.25rem;">
                  <p style="font-weight: 600; color: #1a1a1a; font-size: 0.85rem;">Admin User</p>
                  <p style="color: #9ca3af; font-size: 0.72rem; margin-top: 0.15rem;">admin@enroutehome.zm</p>
                </li>
                <.admin_menu_item href={~p"/admin/profile"} icon="hero-user-circle" label="My Profile" />
                <.admin_menu_item href={~p"/admin/settings"} icon="hero-cog-6-tooth" label="Settings" />
                <li style="border-top: 1px solid #E8E2D9; margin-top: 0.25rem; padding-top: 0.25rem;">
                  <.link href={~p"/users/log-out"} method="delete"
                         style="display: flex; align-items: center; gap: 0.6rem; padding: 0.5rem 0.75rem; border-radius: 0.5rem; color: #dc2626; text-decoration: none; transition: background 0.15s;"
                         onmouseover="this.style.background='#fef2f2'"
                         onmouseout="this.style.background='transparent'">
                    <.icon name="hero-arrow-right-on-rectangle" class="size-4" /> Log out
                  </.link>
                </li>
              </ul>
            </div>
          </div>
        </header>

        <main style="flex: 1; background: #F4F2EF;">
          <.flash_group flash={@flash} />
          {render_slot(@inner_block)}
        </main>

      </div>

      <%!-- SIDEBAR --%>
      <div class="drawer-side" style="z-index: 40;">
        <label for="admin-sidebar" aria-label="close sidebar" class="drawer-overlay"></label>
        <aside style="min-height: 100%; width: 256px; background: #ffffff; border-right: 1px solid #E8E2D9; display: flex; flex-direction: column;">

          <div style="height: 64px; padding: 0 1.25rem; display: flex; align-items: center; gap: 0.75rem; border-bottom: 1px solid #E8E2D9; flex-shrink: 0;">
            <div style="width: 32px; height: 32px; border-radius: 0.5rem; background: #8B1A1A; color: #fff; font-size: 0.85rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">♛</div>
            <div>
              <p style="color: #8B1A1A; font-weight: 700; font-size: 0.82rem; letter-spacing: 0.12em; text-transform: uppercase; line-height: 1.2;">Enroute Home</p>
              <p style="color: #9ca3af; font-size: 0.65rem; letter-spacing: 0.06em;">Admin Portal</p>
            </div>
          </div>

          <nav style="flex: 1; padding: 1.25rem 0.75rem; overflow-y: auto;">
            <.sidebar_group label="Overview" />
            <.sidebar_link href={~p"/admin/dashboard"} icon="hero-squares-2x2"      label="Dashboard"      active={@current_page == :dashboard} />

            <.sidebar_group label="Content" />
            <.sidebar_link href={~p"/admin/sites"}     icon="hero-map-pin"           label="Sites"          active={@current_page == :sites} />
            <.sidebar_link href={~p"/admin/events"}    icon="hero-calendar-days"     label="Events"         active={@current_page == :events} />
            <.sidebar_link href={~p"/admin/foods"}     icon="hero-cake"              label="Foods"          active={@current_page == :foods} />
            <.sidebar_link href={~p"/admin/audio"}     icon="hero-musical-note"      label="Audio"          active={@current_page == :audio} />
            <.sidebar_link href={~p"/admin/media"}     icon="hero-photo"             label="Media"          active={@current_page == :media} />

            <.sidebar_group label="Trips" />
            <.sidebar_link href={~p"/admin/trips"}     icon="hero-map"               label="Trips"          active={@current_page == :trips} />
            <.sidebar_link href={~p"/admin/roads"}     icon="hero-map"               label="Road Operators"          active={@current_page == :roads} />
            <.sidebar_link href={~p"/admin/airline"}     icon="hero-map"               label="Airlines"          active={@current_page == :airline} />


            <.sidebar_group label="Accommodation" />
            <.sidebar_link href={~p"/admin/accomodations"} icon="hero-building-office-2" label="Accommodations" active={@current_page == :accommodations} />
            <.sidebar_link href={~p"/admin/bookings"}      icon="hero-bookmark"          label="Bookings"       active={@current_page == :bookings} />
            <.sidebar_link href={~p"/admin/reviews"}       icon="hero-star"              label="Reviews"        active={@current_page == :reviews} />

            <.sidebar_group label="System" />
            <.sidebar_link href={~p"/admin/users"}    icon="hero-users"              label="Users & Roles"  active={@current_page == :users} />
            <.sidebar_link href={~p"/admin/settings"} icon="hero-cog-6-tooth"        label="Settings"       active={@current_page == :settings} />
          </nav>

          <div style="padding: 0.75rem; border-top: 1px solid #E8E2D9; flex-shrink: 0;">
            <.link href={~p"/users/log-out"} method="delete"
                   style="display: flex; align-items: center; gap: 0.75rem; padding: 0.6rem 0.75rem; border-radius: 0.5rem; font-size: 0.82rem; color: #6b7280; text-decoration: none; transition: background 0.15s, color 0.15s;"
                   onmouseover="this.style.background='#fef2f2'; this.style.color='#dc2626'"
                   onmouseout="this.style.background='transparent'; this.style.color='#6b7280'">
              <.icon name="hero-arrow-right-on-rectangle" class="size-4" />
              <span>Log out</span>
            </.link>
            <p style="font-size: 0.65rem; color: #d1d5db; margin-top: 0.6rem; padding: 0 0.75rem;">
              © {Date.utc_today().year} Enroute Home Digital Heritage
            </p>
          </div>

        </aside>
      </div>
    </div>
    """
  end

  # ───────────────────────────────────────────────
  #  DEFAULT PHOENIX LAYOUT (keep as-is)
  # ───────────────────────────────────────────────
  attr :flash,         :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li><a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a></li>
          <li><a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a></li>
          <li><.theme_toggle /></li>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>
    <main>
      <div>{render_slot(@inner_block)}</div>
    </main>
    <.flash_group flash={@flash} />
    """
  end

  # ───────────────────────────────────────────────
  #  FLASH GROUP
  # ───────────────────────────────────────────────
  attr :flash, :map, required: true
  attr :id,    :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info}  flash={@flash} />
      <.flash kind={:error} flash={@flash} />
      <.flash id="client-error" kind={:error} title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})} hidden>
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
      <.flash id="server-error" kind={:error} title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})} hidden>
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  # ───────────────────────────────────────────────
  #  THEME TOGGLE
  # ───────────────────────────────────────────────
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />
      <button class="flex p-2 cursor-pointer w-1/3" phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="system">
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
      <button class="flex p-2 cursor-pointer w-1/3" phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="light">
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
      <button class="flex p-2 cursor-pointer w-1/3" phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="dark">
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  # ───────────────────────────────────────────────
  #  PUBLIC NAV SUB-COMPONENTS
  # ───────────────────────────────────────────────
    attr :href,   :string,  required: true
    attr :label,  :string,  required: true
    attr :active, :boolean, default: false

    defp nav_link(assigns) do
      ~H"""
      <a href={@href}
        class={[
          "hover:text-zm-copper transition-colors whitespace-nowrap text-sm font-medium",
          (@active && "text-zm-copper") || "text-zm-body"
        ]}>
        {@label}
      </a>
      """
    end

    attr :href,   :string,  required: true
    attr :label,  :string,  required: true
    attr :active, :boolean, default: false
    slot :item, required: true do
      attr :href, :string, required: true
    end

    defp nav_dropdown(assigns) do
      ~H"""
      <div class="relative group">
        <a href={@href}
          class={[
            "flex items-center gap-1 hover:text-zm-copper transition-colors text-sm whitespace-nowrap font-medium",
            (@active && "text-zm-copper") || "text-zm-body"
          ]}>
          {@label}
          <svg class="w-3 h-3 mt-0.5 transition-transform duration-200 group-hover:rotate-180"
              fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </a>
        <div class="absolute top-full left-1/2 -translate-x-1/2 mt-2 w-56
                    opacity-0 invisible translate-y-1
                    group-hover:opacity-100 group-hover:visible group-hover:translate-y-0
                    transition-all duration-200 z-50
                    bg-white/95 backdrop-blur-md border border-zm-copper/15
                    rounded-xl shadow-xl p-1.5">
          <%= for item <- @item do %>
            <a href={item.href}
              class="block px-4 py-2.5 text-sm text-zm-body rounded-lg transition-colors
                      hover:bg-zm-copper/10 hover:text-zm-copper">
              {render_slot(item)}
            </a>
          <% end %>
        </div>
      </div>
      """
    end

  # ───────────────────────────────────────────────
  #  ADMIN SIDEBAR SUB-COMPONENTS
  # ───────────────────────────────────────────────
  attr :label, :string, required: true

  defp sidebar_group(assigns) do
    ~H"""
    <p style="font-size: 0.62rem; font-weight: 700; letter-spacing: 0.18em; text-transform: uppercase; color: rgba(139,26,26,0.45); padding: 0 0.75rem; margin: 1.25rem 0 0.35rem;">
      {@label}
    </p>
    """
  end

  attr :href,   :string,  required: true
  attr :icon,   :string,  required: true
  attr :label,  :string,  required: true
  attr :active, :boolean, default: false

  defp sidebar_link(assigns) do
    ~H"""
    <a href={@href}
       style={sidebar_link_style(@active)}
       onmouseover={if !@active, do: "this.style.background='rgba(139,26,26,0.05)'; this.style.color='#8B1A1A'"}
       onmouseout={if !@active, do: "this.style.background='transparent'; this.style.color='#4b5563'"}>
      <.icon name={@icon} class="size-4" style="flex-shrink: 0;" />
      <span>{@label}</span>
    </a>
    """
  end

  defp sidebar_link_style(true),
    do: "display: flex; align-items: center; gap: 0.75rem; padding: 0.55rem 0.75rem; padding-left: calc(0.75rem - 3px); border-radius: 0.5rem; font-size: 0.82rem; font-weight: 600; color: #8B1A1A; background: rgba(139,26,26,0.08); border-left: 3px solid #8B1A1A; text-decoration: none; margin-bottom: 0.1rem;"

  defp sidebar_link_style(false),
    do: "display: flex; align-items: center; gap: 0.75rem; padding: 0.55rem 0.75rem; padding-left: calc(0.75rem - 3px); border-radius: 0.5rem; font-size: 0.82rem; color: #4b5563; background: transparent; border-left: 3px solid transparent; text-decoration: none; margin-bottom: 0.1rem; transition: background 0.15s, color 0.15s;"

  attr :href,  :string, required: true
  attr :icon,  :string, required: true
  attr :label, :string, required: true

  defp admin_menu_item(assigns) do
    ~H"""
    <li>
      <a href={@href}
         style="display: flex; align-items: center; gap: 0.6rem; padding: 0.5rem 0.75rem; border-radius: 0.5rem; color: #4b5563; text-decoration: none; transition: background 0.15s, color 0.15s;"
         onmouseover="this.style.background='rgba(139,26,26,0.05)'; this.style.color='#8B1A1A'"
         onmouseout="this.style.background='transparent'; this.style.color='#4b5563'">
        <.icon name={@icon} class="size-4" /> {@label}
      </a>
    </li>
    """
  end
end
