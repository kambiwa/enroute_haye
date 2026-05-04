defmodule EnrouteHayeWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use EnrouteHayeWeb, :html

  embed_templates "layouts/*"

  # ───────────────────────────────────────────────
  #  DROP DOWN NAV COMPONENT
  # ───────────────────────────────────────────────
  attr :href,  :string, required: true
  attr :class, :string, default: ""
  attr :rest,  :global
  slot :inner_block, required: true
  slot :items,       required: true

  defp drop_down(assigns) do
    ~H"""
    <div class="relative group">
      <a href={@href} class={["flex items-center gap-1", @class]} {@rest}>
        {render_slot(@inner_block)}
        <svg
          class="w-3 h-3 mt-0.5 transition-transform duration-200 group-hover:rotate-180"
          fill="none" stroke="currentColor" viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </a>

      <div class="
        absolute top-full left-1/2 -translate-x-1/2
        mt-8 w-48
        text-sm text-black
        bg-white border border-white/10 rounded
        opacity-0 invisible
        group-hover:opacity-100 group-hover:visible
        transition-all duration-200
        shadow-lg z-50
      ">
        <div class="py-1">
          {render_slot(@items)}
        </div>
      </div>
    </div>
    """
  end

  # ───────────────────────────────────────────────
  #  PUBLIC / UNAUTHENTICATED LAYOUT
  # ───────────────────────────────────────────────
  attr :flash,         :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def unauth_app(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col kuomboka-bg">

      <%!-- ═══════════════════════════════════════════
           NAV — three zones: logo | links | actions
      ════════════════════════════════════════════════ --%>
      <nav
        style="background: rgba(28,43,26,.88); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); border-bottom: 1px solid rgba(255,255,255,.08);"
        class="fixed top-0 left-0 right-0 z-50">

        <div class="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between gap-8">

          <%!-- ── LOGO ── --%>
          <a href={~p"/"} class="flex items-center gap-2 flex-shrink-0">
            <div class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white"
              style="background: linear-gradient(135deg, #E8B94A, #2D6A2D);">EH</div>
            <span class="text-white font-semibold tracking-wide text-sm leading-tight">
              ENROUTE<br><span style="color: #E8B94A;">HAYE</span>
            </span>
          </a>

          <%!-- ── CENTER NAV LINKS ── --%>
          <div class="hidden md:flex items-center gap-6 text-sm flex-1 justify-center" style="color: rgba(255,255,255,.75);">
            <a href={~p"/#barge"} class="hover:text-amber-400 transition-colors whitespace-nowrap">
              Destinations
            </a>
            <a href="#" class="hover:text-amber-400 transition-colors whitespace-nowrap">
              Experiences
            </a>
            <.drop_down href={~p"/#ceremony"} class="text-white/75 hover:text-amber-400 text-sm transition-colors">
              Ceremony
              <:items>
                <a href={~p"/mize"}     class="block px-4 py-2 text-sm text-gray-700 hover:text-amber-500 hover:bg-gray-50 transition-colors">Mize</a>
                <a href={~p"/kuomboka"} class="block px-4 py-2 text-sm text-gray-700 hover:text-amber-500 hover:bg-gray-50 transition-colors">Kuomboka</a>
              </:items>
            </.drop_down>
            <a href={~p"/journey"} class="hover:text-amber-400 transition-colors whitespace-nowrap">
              Plan Your Trip
            </a>
            <a href="#" class="hover:text-amber-400 transition-colors whitespace-nowrap">
              Events &amp; Ceremonies
            </a>
            <a href="#" class="hover:text-amber-400 transition-colors whitespace-nowrap">
              Discover Zambia
            </a>
          </div>

          <%!-- ── RIGHT ACTIONS ── --%>
          <div class="hidden md:flex items-center gap-3 flex-shrink-0">
            <%!-- Icon: Search --%>
            <button style="color: rgba(255,255,255,.65);" class="hover:text-white transition-colors p-1">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
              </svg>
            </button>

            <%!-- Icon: Wishlist --%>
            <button style="color: rgba(255,255,255,.65);" class="hover:text-white transition-colors p-1">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
              </svg>
            </button>

            <%!-- Divider --%>
            <div style="width: 1px; height: 18px; background: rgba(255,255,255,.15);"></div>

            <%!-- Sign in --%>
            <a href={~p"/users/log-in"} style="color: rgba(255,255,255,.7); font-size: .875rem;" class="hover:text-white transition-colors whitespace-nowrap">
              Sign in
            </a>

            <%!-- Plan Trip CTA --%>
            <a href={~p"/journey"}>
              <button
                style="background: linear-gradient(110deg,#C9A84C 0%,#E8B94A 40%,#fff8e0 50%,#E8B94A 60%,#C9A84C 100%); background-size: 200% auto; color: #1a1a00; font-weight: 700; font-size: .8rem; padding: .45rem 1.1rem; border-radius: 9999px; border: none; cursor: pointer; white-space: nowrap; transition: box-shadow .3s, background-position .6s;">
                Plan Trip
              </button>
            </a>
          </div>

          <%!-- ── MOBILE HAMBURGER ── --%>
          <button class="md:hidden text-white p-2 flex-shrink-0" aria-label="Toggle menu">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
          </button>

        </div>
      </nav>

      <main class="flex-1 pt-16">
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </main>

      <footer class="footer bg-gray-950 border-t border-yellow-400/20 text-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-8">

            <div class="md:col-span-2">
              <div class="flex items-center gap-2 mb-4">
                <span class="text-yellow-400 text-2xl">♛</span>
                <span class="font-bold tracking-widest text-sm uppercase">Enroute Home</span>
              </div>
              <p class="text-white/60 text-sm leading-relaxed">
                Preserving and sharing the rich cultural heritage of the Lozi people
                and the magnificent Kuomboka ceremony for future generations.
              </p>
              <div class="flex gap-3 mt-4">
                <a href="#" aria-label="Facebook"
                   class="w-8 h-8 border border-white/20 rounded-full flex items-center justify-center text-white/60 hover:border-yellow-400 hover:text-yellow-400 transition-all text-xs">
                  f
                </a>
                <a href="#" aria-label="Instagram"
                   class="w-8 h-8 border border-white/20 rounded-full flex items-center justify-center text-white/60 hover:border-yellow-400 hover:text-yellow-400 transition-all text-xs">
                  ◎
                </a>
                <a href="#" aria-label="Twitter"
                   class="w-8 h-8 border border-white/20 rounded-full flex items-center justify-center text-white/60 hover:border-yellow-400 hover:text-yellow-400 transition-all text-xs">
                  ✕
                </a>
              </div>
            </div>

            <div>
              <h4 class="text-yellow-400 text-xs font-semibold tracking-widest uppercase mb-4">Quick Links</h4>
              <ul class="space-y-2 text-sm text-white/60">
                <li><a href={~p"/#ceremony"} class="hover:text-yellow-400 transition-colors">The Ceremony</a></li>
                <li><a href={~p"/#journey"}  class="hover:text-yellow-400 transition-colors">Royal History</a></li>
                <li><a href={~p"/journey"}   class="hover:text-yellow-400 transition-colors">Visit Barotseland</a></li>
                <li><a href="#"              class="hover:text-yellow-400 transition-colors">Cultural Guidelines</a></li>
              </ul>
            </div>

            <div>
              <h4 class="text-yellow-400 text-xs font-semibold tracking-widest uppercase mb-4">Contact</h4>
              <ul class="space-y-2 text-sm text-white/60">
                <li>📍 Zambia</li>
                <li>✉ <a href="mailto:info@enroutehome.zm" class="hover:text-yellow-400 transition-colors">info@enroutehome.zm</a></li>
              </ul>
            </div>

          </div>

          <div class="border-t border-white/10 mt-10 pt-6 flex flex-col sm:flex-row justify-between items-center gap-2 text-xs text-white/40">
            <p>© {Date.utc_today().year} Enroute Home Digital Heritage. All rights reserved.</p>
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
  #  UNAUTHENTICATED LAYOUT — navbar only, no footer
  # ───────────────────────────────────────────────
  attr :flash,         :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def unauth_no_footer(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col kuomboka-bg">

      <nav id="navbar-hook"
           class="navbar visible fixed top-0 left-0 right-0 z-50 transition-all duration-300"
           phx-hook="Navbar">
        <div class="navbar-inner max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full flex items-center justify-between h-16">

          <a href={~p"/"} class="navbar-brand flex items-center gap-2">
            <span class="brand-crown text-yellow-400 text-2xl">♛</span>
            <span class="brand-name text-white font-bold tracking-widest text-sm uppercase">Enroute Home</span>
          </a>

          <div class="navbar-links hidden md:flex items-center gap-6">
            <a href={~p"/#journey"}  class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">The Journey</a>
            <a href={~p"/#ceremony"} class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">Ceremony</a>
            <a href={~p"/#barge"}    class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">Nalikwanda</a>
            <a href={~p"/#culture"}  class="nav-link text-white/80 hover:text-yellow-400 text-sm tracking-wide transition-colors">Culture</a>
            <a href={~p"/journey"}   class="btn-outline-gold border border-yellow-400 text-yellow-400 hover:bg-yellow-400 hover:text-black px-4 py-1.5 rounded text-sm tracking-wide transition-all">Start Tour</a>
            <a href={~p"/users/log-in"} class="text-white/70 hover:text-white text-sm transition-colors">Sign in</a>
          </div>

          <button class="md:hidden text-white p-2" phx-click="toggle_mobile_menu" aria-label="Toggle menu">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
          </button>

        </div>
      </nav>

      <main class="flex-1 pt-16">
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </main>

    </div>
    """
  end

  # ───────────────────────────────────────────────
  #  ADMIN / BACKOFFICE LAYOUT
  # ───────────────────────────────────────────────
  attr :flash,        :map,    required: true
  attr :page_title,   :string, default: "Dashboard"
  attr :current_page, :atom,   default: :dashboard
  attr :current_scope, :map,   default: nil
  slot :inner_block, required: true

  def admin_app(assigns) do
    ~H"""
    <div class="drawer lg:drawer-open min-h-screen">
      <input id="admin-sidebar" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">

        <header style="position: sticky; top: 0; z-index: 30; display: flex; align-items: center;
                       height: 64px; padding: 0 1.5rem; background: #ffffff;
                       border-bottom: 1px solid #E8E2D9;
                       box-shadow: 0 1px 4px rgba(0,0,0,0.06);">

          <label for="admin-sidebar" class="lg:hidden" aria-label="Open sidebar"
                 style="display: flex; align-items: center; justify-content: center;
                        width: 36px; height: 36px; margin-right: 0.75rem;
                        border-radius: 0.5rem; cursor: pointer;
                        border: 1px solid #E8E2D9; color: #8B1A1A;">
            <.icon name="hero-bars-3" class="size-5" />
          </label>

          <div style="flex: 1;">
            <h1 style="font-size: 0.95rem; font-weight: 600; color: #1a1a1a; letter-spacing: 0.01em;">
              {@page_title}
            </h1>
          </div>

          <div style="display: flex; align-items: center; gap: 0.5rem;">

            <button aria-label="Notifications"
                    style="width: 36px; height: 36px; border-radius: 0.5rem; border: none;
                           background: transparent; color: #9ca3af; cursor: pointer;
                           display: flex; align-items: center; justify-content: center;
                           transition: background 0.15s, color 0.15s;"
                    onmouseover="this.style.background='rgba(139,26,26,0.06)'; this.style.color='#8B1A1A'"
                    onmouseout="this.style.background='transparent'; this.style.color='#9ca3af'">
              <.icon name="hero-bell" class="size-5" />
            </button>

            <div style="width: 1px; height: 24px; background: #E8E2D9; margin: 0 0.25rem;"></div>

            <div class="dropdown dropdown-end">
              <label tabindex="0"
                     style="display: flex; align-items: center; gap: 0.6rem; cursor: pointer;
                            padding: 0.35rem 0.6rem; border-radius: 0.5rem;
                            transition: background 0.15s;"
                     onmouseover="this.style.background='#F9F7F4'"
                     onmouseout="this.style.background='transparent'">
                <div style="width: 32px; height: 32px; border-radius: 50%;
                            background: #8B1A1A; color: #fff;
                            display: flex; align-items: center; justify-content: center;
                            font-size: 0.75rem; font-weight: 700; flex-shrink: 0;">
                  A
                </div>
                <div class="hidden sm:block" style="text-align: left; line-height: 1.3;">
                  <p style="font-size: 0.82rem; font-weight: 600; color: #1a1a1a;">Admin</p>
                  <p style="font-size: 0.68rem; color: #9ca3af;">Administrator</p>
                </div>
                <.icon name="hero-chevron-down" class="size-3.5 hidden sm:block" style="color: #9ca3af;" />
              </label>

              <ul tabindex="0" class="dropdown-content"
                  style="z-index: 50; margin-top: 0.5rem; width: 224px;
                         background: #fff; border-radius: 0.75rem;
                         box-shadow: 0 8px 24px rgba(0,0,0,0.1);
                         border: 1px solid #E8E2D9; padding: 0.375rem;
                         font-size: 0.85rem; list-style: none;">
                <li style="padding: 0.6rem 0.75rem; border-bottom: 1px solid #E8E2D9; margin-bottom: 0.25rem;">
                  <p style="font-weight: 600; color: #1a1a1a; font-size: 0.85rem;">Admin User</p>
                  <p style="color: #9ca3af; font-size: 0.72rem; margin-top: 0.15rem;">admin@enroutehome.zm</p>
                </li>
                <li>
                  <a href={~p"/admin/profile"}
                     style="display: flex; align-items: center; gap: 0.6rem; padding: 0.5rem 0.75rem;
                            border-radius: 0.5rem; color: #4b5563; text-decoration: none;
                            transition: background 0.15s, color 0.15s;"
                     onmouseover="this.style.background='rgba(139,26,26,0.05)'; this.style.color='#8B1A1A'"
                     onmouseout="this.style.background='transparent'; this.style.color='#4b5563'">
                    <.icon name="hero-user-circle" class="size-4" /> My Profile
                  </a>
                </li>
                <li>
                  <a href={~p"/admin/settings"}
                     style="display: flex; align-items: center; gap: 0.6rem; padding: 0.5rem 0.75rem;
                            border-radius: 0.5rem; color: #4b5563; text-decoration: none;
                            transition: background 0.15s, color 0.15s;"
                     onmouseover="this.style.background='rgba(139,26,26,0.05)'; this.style.color='#8B1A1A'"
                     onmouseout="this.style.background='transparent'; this.style.color='#4b5563'">
                    <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
                  </a>
                </li>
                <li style="border-top: 1px solid #E8E2D9; margin-top: 0.25rem; padding-top: 0.25rem;">
                  <.link href={~p"/users/log-out"} method="delete"
                         style="display: flex; align-items: center; gap: 0.6rem; padding: 0.5rem 0.75rem;
                                border-radius: 0.5rem; color: #dc2626; text-decoration: none;
                                transition: background 0.15s;"
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

      <div class="drawer-side" style="z-index: 40;">
        <label for="admin-sidebar" aria-label="close sidebar" class="drawer-overlay"></label>

        <aside style="min-height: 100%; width: 256px; background: #ffffff;
                      border-right: 1px solid #E8E2D9;
                      display: flex; flex-direction: column;">

          <div style="height: 64px; padding: 0 1.25rem; display: flex; align-items: center;
                      gap: 0.75rem; border-bottom: 1px solid #E8E2D9; flex-shrink: 0;">
            <div style="width: 32px; height: 32px; border-radius: 0.5rem;
                        background: #8B1A1A; color: #fff; font-size: 0.85rem;
                        display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
              ♛
            </div>
            <div>
              <p style="color: #8B1A1A; font-weight: 700; font-size: 0.82rem;
                        letter-spacing: 0.12em; text-transform: uppercase; line-height: 1.2;">
                Enroute Home
              </p>
              <p style="color: #9ca3af; font-size: 0.65rem; letter-spacing: 0.06em;">Admin Portal</p>
            </div>
          </div>

          <nav style="flex: 1; padding: 1.25rem 0.75rem; overflow-y: auto;">
            <.nav_group label="Overview" />
            <.nav_link href={~p"/admin/dashboard"} icon="hero-squares-2x2"       label="Dashboard"      active={@current_page == :dashboard} />

            <.nav_group label="Content" />
            <.nav_link href={~p"/admin/sites"}  icon="hero-map-pin"               label="Sites"          active={@current_page == :sites} />
            <.nav_link href={~p"/admin/events"} icon="hero-calendar-days"         label="Events"         active={@current_page == :events} />
            <.nav_link href={~p"/admin/foods"}  icon="hero-cake"                  label="Foods"          active={@current_page == :foods} />
            <.nav_link href={~p"/admin/audio"}  icon="hero-musical-note"          label="Audio"          active={@current_page == :audio} />
            <.nav_link href={~p"/admin/media"}  icon="hero-photo"                 label="Media"          active={@current_page == :media} />

            <.nav_group label="Trips" />
            <.nav_link href={~p"/admin/trips"}  icon="hero-map"                   label="Trips"          active={@current_page == :trips} />

            <.nav_group label="Accommodation" />
            <.nav_link href={~p"/admin/accomodations"} icon="hero-building-office-2" label="Accommodations" active={@current_page == :accommodations} />
            <.nav_link href={~p"/admin/bookings"}      icon="hero-bookmark"          label="Bookings"       active={@current_page == :bookings} />
            <.nav_link href={~p"/admin/reviews"}       icon="hero-star"              label="Reviews"        active={@current_page == :reviews} />

            <.nav_group label="System" />
            <.nav_link href={~p"/admin/users"}    icon="hero-users"       label="Users & Roles"  active={@current_page == :users} />
            <.nav_link href={~p"/admin/settings"} icon="hero-cog-6-tooth" label="Settings"       active={@current_page == :settings} />
          </nav>

          <div style="padding: 0.75rem; border-top: 1px solid #E8E2D9; flex-shrink: 0;">
            <.link href={~p"/users/log-out"} method="delete"
                   style="display: flex; align-items: center; gap: 0.75rem;
                          padding: 0.6rem 0.75rem; border-radius: 0.5rem;
                          font-size: 0.82rem; color: #6b7280; text-decoration: none;
                          transition: background 0.15s, color 0.15s;"
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
  #  DEFAULT PHOENIX APP LAYOUT
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
  #  SIDEBAR SUB-COMPONENTS (admin only)
  # ───────────────────────────────────────────────
  attr :label, :string, required: true

  defp nav_group(assigns) do
    ~H"""
    <p style="font-size: 0.62rem; font-weight: 700; letter-spacing: 0.18em;
              text-transform: uppercase; color: rgba(139,26,26,0.45);
              padding: 0 0.75rem; margin: 1.25rem 0 0.35rem;">
      {@label}
    </p>
    """
  end

  attr :href,   :string,  required: true
  attr :icon,   :string,  required: true
  attr :label,  :string,  required: true
  attr :active, :boolean, default: false

  defp nav_link(assigns) do
    ~H"""
    <a href={@href}
       style={nav_link_style(@active)}
       onmouseover={if !@active, do: "this.style.background='rgba(139,26,26,0.05)'; this.style.color='#8B1A1A'"}
       onmouseout={if !@active, do: "this.style.background='transparent'; this.style.color='#4b5563'"}>
      <.icon name={@icon} class="size-4" style="flex-shrink: 0;" />
      <span>{@label}</span>
    </a>
    """
  end

  defp nav_link_style(true) do
    "display: flex; align-items: center; gap: 0.75rem; padding: 0.55rem 0.75rem;
     padding-left: calc(0.75rem - 3px); border-radius: 0.5rem;
     font-size: 0.82rem; font-weight: 600; color: #8B1A1A;
     background: rgba(139,26,26,0.08); border-left: 3px solid #8B1A1A;
     text-decoration: none; margin-bottom: 0.1rem;"
  end

  defp nav_link_style(false) do
    "display: flex; align-items: center; gap: 0.75rem; padding: 0.55rem 0.75rem;
     padding-left: calc(0.75rem - 3px); border-radius: 0.5rem;
     font-size: 0.82rem; color: #4b5563; background: transparent;
     border-left: 3px solid transparent; text-decoration: none;
     margin-bottom: 0.1rem; transition: background 0.15s, color 0.15s;"
  end
end
