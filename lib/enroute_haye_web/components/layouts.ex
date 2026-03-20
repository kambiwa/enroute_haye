defmodule EnrouteHayeWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use EnrouteHayeWeb, :html

  embed_templates "layouts/*"

  # ───────────────────────────────────────────────
  #  PUBLIC / UNAUTHENTICATED LAYOUT  (Kuomboka style)
  # ───────────────────────────────────────────────
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def unauth_app(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col kuomboka-bg">

      <%!-- ── NAVBAR ── --%>
      <nav id="navbar" class="navbar fixed top-0 left-0 right-0 z-50 transition-all duration-300"
           phx-hook="Navbar" id="navbar-hook">
        <div class="navbar-inner max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full flex items-center justify-between h-16">

          <a href={~p"/"} class="navbar-brand flex items-center gap-2">
            <span class="brand-crown text-yellow-400 text-2xl">♛</span>
            <span class="brand-name text-white font-bold tracking-widest text-sm uppercase">KUOMBOKA</span>
          </a>

          <%!-- Desktop links --%>
          <div class="navbar-links hidden md:flex items-center gap-6">
            <a href={~p"/#journey"}   class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">The Journey</a>
            <a href={~p"/#ceremony"}  class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">Ceremony</a>
            <a href={~p"/#barge"}     class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">Nalikwanda</a>
            <a href={~p"/#culture"}   class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">Culture</a>
            <a href={~p"/journey"}    class="btn-outline-gold border border-yellow-400 text-yellow-400 hover:bg-yellow-400 hover:text-black px-4 py-1.5 rounded text-sm tracking-wide transition-all">Start Tour</a>
            <a href={~p"/users/log-in"}   class="text-white/70 hover:text-white text-sm transition-colors">Sign in</a>
            <a href={~p"/users/register"} class="bg-yellow-400 text-black font-semibold px-4 py-1.5 rounded text-sm hover:bg-yellow-300 transition-colors">Get Started</a>
          </div>

          <%!-- Mobile hamburger — wired to LiveView toggle --%>
          <button class="md:hidden text-white p-2"
                  phx-click="toggle_mobile_menu"
                  aria-label="Toggle menu">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
          </button>
        </div>
      </nav>

      <%!-- ── MAIN ── --%>
      <main class="flex-1 pt-16">
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </main>

      <%!-- ── FOOTER ── --%>
      <footer class="footer bg-gray-950 border-t border-yellow-400/20 text-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-8">

            <%!-- Brand --%>
            <div class="md:col-span-2">
              <div class="flex items-center gap-2 mb-4">
                <span class="text-yellow-400 text-2xl">♛</span>
                <span class="font-bold tracking-widest text-sm uppercase">KUOMBOKA</span>
              </div>
              <p class="text-white/60 text-sm leading-relaxed">
                Preserving and sharing the rich cultural heritage of the Lozi people
                and the magnificent Kuomboka ceremony for future generations.
              </p>
              <div class="flex gap-3 mt-4">
                <a href="#" class="w-8 h-8 border border-white/20 rounded-full flex items-center justify-center text-white/60 hover:border-yellow-400 hover:text-yellow-400 transition-all text-xs" aria-label="Facebook">f</a>
                <a href="#" class="w-8 h-8 border border-white/20 rounded-full flex items-center justify-center text-white/60 hover:border-yellow-400 hover:text-yellow-400 transition-all text-xs" aria-label="Instagram">◎</a>
                <a href="#" class="w-8 h-8 border border-white/20 rounded-full flex items-center justify-center text-white/60 hover:border-yellow-400 hover:text-yellow-400 transition-all text-xs" aria-label="Twitter">✕</a>
              </div>
            </div>

            <%!-- Quick Links --%>
            <div>
              <h4 class="text-yellow-400 text-xs font-semibold tracking-widest uppercase mb-4">Quick Links</h4>
              <ul class="space-y-2 text-sm text-white/60">
                <li><a href={~p"/#ceremony"} class="hover:text-yellow-400 transition-colors">The Ceremony</a></li>
                <li><a href={~p"/#journey"}  class="hover:text-yellow-400 transition-colors">Royal History</a></li>
                <li><a href={~p"/journey"}   class="hover:text-yellow-400 transition-colors">Visit Barotseland</a></li>
                <li><a href="#"              class="hover:text-yellow-400 transition-colors">Cultural Guidelines</a></li>
              </ul>
            </div>

            <%!-- Contact --%>
            <div>
              <h4 class="text-yellow-400 text-xs font-semibold tracking-widest uppercase mb-4">Contact</h4>
              <ul class="space-y-2 text-sm text-white/60">
                <li>📍 Mongu, Western Zambia</li>
                <li>✉ <a href="mailto:info@kuomboka.zm" class="hover:text-yellow-400 transition-colors">info@kuomboka.zm</a></li>
              </ul>
            </div>
          </div>

          <div class="border-t border-white/10 mt-10 pt-6 flex flex-col sm:flex-row justify-between items-center gap-2 text-xs text-white/40">
            <p>© {Date.utc_today().year} Kuomboka Digital Heritage. All rights reserved.</p>
            <div class="flex gap-4">
              <a href="#" class="hover:text-white/70 transition-colors">Privacy</a>
              <a href="#" class="hover:text-white/70 transition-colors">Terms</a>
              <a href="#" class="hover:text-white/70 transition-colors">WhatsApp</a>
              <a href="#" class="hover:text-white/70 transition-colors">Facebook</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
    """
  end

  # ───────────────────────────────────────────────
  #  ADMIN / BACKOFFICE LAYOUT
  # ───────────────────────────────────────────────
  attr :flash, :map, required: true
  attr :page_title, :string, default: "Dashboard"
  attr :current_page, :atom, default: :dashboard
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def admin_app(assigns) do
    ~H"""
    <div class="drawer lg:drawer-open min-h-screen">
      <input id="admin-sidebar" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">

        <%!-- ══════════════════════════════════════════
             TOP NAV — white bar, crimson accents
        ══════════════════════════════════════════ --%>
        <header class="sticky top-0 z-30 flex items-center h-16 px-4 sm:px-6 bg-white border-b border-[#E8E2D9] shadow-sm">

          <%!-- Mobile: hamburger --%>
          <label for="admin-sidebar" class="lg:hidden btn btn-sm btn-ghost mr-3" aria-label="Open sidebar">
            <.icon name="hero-bars-3" class="size-5 text-[#8B1A1A]" />
          </label>

          <%!-- Page title --%>
          <div class="flex-1">
            <h1 class="text-base font-semibold text-gray-800 tracking-wide">{@page_title}</h1>
          </div>

          <%!-- Right side: notifications + profile dropdown --%>
          <div class="flex items-center gap-3">

            <%!-- Bell icon --%>
            <button class="w-9 h-9 rounded-lg flex items-center justify-center text-gray-400 hover:text-[#8B1A1A] hover:bg-[#8B1A1A]/5 transition-all" aria-label="Notifications">
              <.icon name="hero-bell" class="size-5" />
            </button>

            <%!-- Divider --%>
            <div class="w-px h-6 bg-gray-200"></div>

            <%!-- Profile dropdown (DaisyUI) --%>
            <div class="dropdown dropdown-end">
              <label tabindex="0" class="flex items-center gap-2.5 cursor-pointer group px-2 py-1.5 rounded-lg hover:bg-gray-50 transition-colors">
                <%!-- Avatar --%>
                <div class="w-8 h-8 rounded-full bg-[#8B1A1A] flex items-center justify-center text-white text-xs font-bold shrink-0">
                  A
                </div>
                <%!-- Name + role --%>
                <div class="hidden sm:block text-left">
                  <p class="text-sm font-semibold text-gray-800 leading-tight">Admin</p>
                  <p class="text-[11px] text-gray-400 leading-tight">Administrator</p>
                </div>
                <%!-- Chevron --%>
                <.icon name="hero-chevron-down" class="size-3.5 text-gray-400 group-hover:text-[#8B1A1A] transition-colors hidden sm:block" />
              </label>

              <ul tabindex="0"
                  class="dropdown-content z-[50] mt-2 w-56 bg-white rounded-xl shadow-lg border border-[#E8E2D9] p-1.5 text-sm">
                <%!-- User info header --%>
                <li class="px-3 py-2.5 border-b border-[#E8E2D9] mb-1">
                  <p class="font-semibold text-gray-800 text-sm">Admin User</p>
                  <p class="text-gray-400 text-xs mt-0.5">admin@kuomboka.zm</p>
                </li>
                <li>
                  <a href={~p"/admin/profile"}
                     class="flex items-center gap-2.5 px-3 py-2 rounded-lg text-gray-600 hover:text-[#8B1A1A] hover:bg-[#8B1A1A]/5 transition-all">
                    <.icon name="hero-user-circle" class="size-4 shrink-0" />
                    My Profile
                  </a>
                </li>
                <li>
                  <a href={~p"/admin/settings"}
                     class="flex items-center gap-2.5 px-3 py-2 rounded-lg text-gray-600 hover:text-[#8B1A1A] hover:bg-[#8B1A1A]/5 transition-all">
                    <.icon name="hero-cog-6-tooth" class="size-4 shrink-0" />
                    Settings
                  </a>
                </li>
                <li class="border-t border-[#E8E2D9] mt-1 pt-1">
                  <.link href={~p"/users/log-out"} method="delete"
                         class="flex items-center gap-2.5 px-3 py-2 rounded-lg text-red-500 hover:text-red-600 hover:bg-red-50 transition-all w-full">
                    <.icon name="hero-arrow-right-on-rectangle" class="size-4 shrink-0" />
                    Log out
                  </.link>
                </li>
              </ul>
            </div>

          </div>
        </header>

        <%!-- ── MAIN CONTENT ── --%>
        <main class="flex-1 bg-[#F4F2EF]">
          <.flash_group flash={@flash} />
          {render_slot(@inner_block)}
        </main>
      </div>

      <%!-- ══════════════════════════════════════════
           SIDEBAR — single cream panel, crimson accents
      ══════════════════════════════════════════ --%>
      <div class="drawer-side z-40">
        <label for="admin-sidebar" aria-label="close sidebar" class="drawer-overlay"></label>

        <aside class="min-h-full w-64 bg-white border-r border-[#E8E2D9] flex flex-col">

          <%!-- ── Brand / Logo ── --%>
          <div class="h-16 px-5 flex items-center gap-3 border-b border-[#E8E2D9] shrink-0">
            <div class="w-8 h-8 rounded-lg bg-[#8B1A1A] flex items-center justify-center text-white text-sm shrink-0">
              ♛
            </div>
            <div>
              <p class="text-[#8B1A1A] font-bold text-sm tracking-[0.12em] uppercase leading-tight">Kuomboka</p>
              <p class="text-gray-400 text-[10px] tracking-wide">Admin Portal</p>
            </div>
          </div>

          <%!-- ── Scrollable nav ── --%>
          <nav class="flex-1 px-3 py-5 overflow-y-auto space-y-0.5">

            <p class="text-[#8B1A1A]/50 text-[10px] font-bold tracking-[0.2em] uppercase px-3 mb-1.5">Overview</p>
            <a href={~p"/admin/dashboard"} class={sidebar_link(@current_page == :dashboard)}>
              <.icon name="hero-squares-2x2" class="size-4 shrink-0" /><span>Dashboard</span>
            </a>

            <%!-- CONTENT --%>
            <p class="text-[#8B1A1A]/50 text-[10px] font-bold tracking-[0.2em] uppercase px-3 mb-1.5 mt-5">Content</p>
            <a href={~p"/admin/sites"}  class={sidebar_link(@current_page == :sites)}>
              <.icon name="hero-map-pin"       class="size-4 shrink-0" /><span>Sites</span>
            </a>
            <a href={~p"/admin/events"} class={sidebar_link(@current_page == :events)}>
              <.icon name="hero-calendar-days" class="size-4 shrink-0" /><span>Events</span>
            </a>
            <a href={~p"/admin/foods"}  class={sidebar_link(@current_page == :foods)}>
              <.icon name="hero-cake"          class="size-4 shrink-0" /><span>Foods</span>
            </a>
            <a href={~p"/admin/audio"}  class={sidebar_link(@current_page == :audio)}>
              <.icon name="hero-musical-note"  class="size-4 shrink-0" /><span>Audio</span>
            </a>
            <a href={~p"/admin/media"}  class={sidebar_link(@current_page == :media)}>
              <.icon name="hero-photo"         class="size-4 shrink-0" /><span>Media</span>
            </a>

            <%!-- TRIPS --%>
            <p class="text-[#8B1A1A]/50 text-[10px] font-bold tracking-[0.2em] uppercase px-3 mb-1.5 mt-5">Trips</p>
            <a href={~p"/admin/trips"} class={sidebar_link(@current_page == :trips)}>
              <.icon name="hero-map" class="size-4 shrink-0" /><span>Trips</span>
            </a>

            <%!-- ACCOMMODATION --%>
            <p class="text-[#8B1A1A]/50 text-[10px] font-bold tracking-[0.2em] uppercase px-3 mb-1.5 mt-5">Accommodation</p>
            <a href={~p"/admin/accommodations"} class={sidebar_link(@current_page == :accommodations)}>
              <.icon name="hero-building-office-2" class="size-4 shrink-0" /><span>Accommodations</span>
            </a>
            <a href={~p"/admin/bookings"} class={sidebar_link(@current_page == :bookings)}>
              <.icon name="hero-bookmark"          class="size-4 shrink-0" /><span>Bookings</span>
            </a>
            <a href={~p"/admin/reviews"} class={sidebar_link(@current_page == :reviews)}>
              <.icon name="hero-star"              class="size-4 shrink-0" /><span>Reviews</span>
            </a>

            <%!-- SYSTEM --%>
            <p class="text-[#8B1A1A]/50 text-[10px] font-bold tracking-[0.2em] uppercase px-3 mb-1.5 mt-5">System</p>
            <a href={~p"/admin/users"}    class={sidebar_link(@current_page == :users)}>
              <.icon name="hero-users"       class="size-4 shrink-0" /><span>Users &amp; Roles</span>
            </a>
            <a href={~p"/admin/settings"} class={sidebar_link(@current_page == :settings)}>
              <.icon name="hero-cog-6-tooth" class="size-4 shrink-0" /><span>Settings</span>
            </a>

          </nav>

          <%!-- ── Sidebar footer ── --%>
          <div class="px-4 py-4 border-t border-[#E8E2D9] shrink-0">
            <.link href={~p"/users/log-out"} method="delete"
                   class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm text-gray-500 hover:text-red-500 hover:bg-red-50 transition-all group w-full">
              <.icon name="hero-arrow-right-on-rectangle" class="size-4 shrink-0 group-hover:translate-x-0.5 transition-transform" />
              <span>Log out</span>
            </.link>
            <p class="text-[10px] text-gray-300 mt-3 px-3">© {Date.utc_today().year} Kuomboka Digital Heritage</p>
          </div>

        </aside>
      </div>
    </div>
    """
  end

  # ───────────────────────────────────────────────
  #  HELPERS
  # ───────────────────────────────────────────────

  # Sidebar nav link — active state: crimson left border + tinted bg
  defp sidebar_link(true),
    do: "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-semibold text-[#8B1A1A] bg-[#8B1A1A]/8 border-l-[3px] border-[#8B1A1A] pl-[calc(0.75rem-3px)] transition-all"

  defp sidebar_link(false),
    do: "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gray-600 hover:text-[#8B1A1A] hover:bg-[#8B1A1A]/5 border-l-[3px] border-transparent pl-[calc(0.75rem-3px)] transition-all"

  # ───────────────────────────────────────────────
  #  DEFAULT PHOENIX APP LAYOUT (keep for dev/errors)
  # ───────────────────────────────────────────────
  attr :flash, :map, required: true
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
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>
    <.flash_group flash={@flash} />
    """
  end

  # ───────────────────────────────────────────────
  #  FLASH GROUP
  # ───────────────────────────────────────────────
  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

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

  # ───────────────────────────────────────────────
  #  THEME TOGGLE
  # ───────────────────────────────────────────────
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button class="flex p-2 cursor-pointer w-1/3"
              phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="system">
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
      <button class="flex p-2 cursor-pointer w-1/3"
              phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="light">
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
      <button class="flex p-2 cursor-pointer w-1/3"
              phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="dark">
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
