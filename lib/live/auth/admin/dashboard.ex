defmodule EnrouteHayeWeb.Auth.Admin.Dashboard do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Repo

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Dashboard")
      |> assign(:stats, load_stats())
      |> assign(:recent_bookings, load_recent_bookings())
      |> assign(:recent_trips, load_recent_trips())
      |> assign(:upcoming_events, load_upcoming_events())
      |> assign(:monthly_bookings, monthly_booking_counts())
      |> assign(:status_breakdown, booking_status_counts())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin_app flash={@flash} current_scope={@current_scope} current_page={:dashboard}>
      <style>
        @keyframes ehFloat { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
        @keyframes ehPulse { 0%,100% { opacity: 1; transform: scale(1); } 50% { opacity: .45; transform: scale(1.4); } }
        @keyframes ehRise  { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: none; } }
        @keyframes ehGlow  { 0%,100% { opacity: .55; } 50% { opacity: .9; } }
        @keyframes ehShine { from { transform: translateX(-120%) skewX(-18deg); } to { transform: translateX(220%) skewX(-18deg); } }

        .eh-rise { animation: ehRise .6s cubic-bezier(.2,.7,.2,1) both; }

        /* ── Hero ── */
        .eh-hero {
          position: relative; border-radius: 1.4rem; overflow: hidden;
          padding: 2.25rem 2rem 6rem;
          background:
            radial-gradient(circle at 15% 30%, rgba(217,119,6,.32), transparent 42%),
            radial-gradient(circle at 85% 15%, rgba(185,28,28,.6), transparent 48%),
            radial-gradient(circle at 50% 120%, rgba(253,230,138,.18), transparent 55%),
            linear-gradient(135deg, #240707 0%, #551111 45%, #8B1A1A 100%);
          box-shadow: 0 24px 50px -18px rgba(92,19,19,.45);
        }
        .eh-hero-dots {
          position: absolute; inset: 0; pointer-events: none;
          background-image: radial-gradient(rgba(255,255,255,.09) 1px, transparent 1px);
          background-size: 22px 22px;
          -webkit-mask-image: linear-gradient(to bottom, #000 40%, transparent);
                  mask-image: linear-gradient(to bottom, #000 40%, transparent);
        }
        .eh-hero-ring {
          position: absolute; border-radius: 999px; pointer-events: none;
          border: 1px solid rgba(253,230,138,.18); animation: ehGlow 5s ease-in-out infinite;
        }
        .eh-hero-wave { position: absolute; left: 0; right: 0; bottom: -1px; width: 100%; height: 70px; pointer-events: none; }
        .eh-cutout {
          position: absolute; bottom: -4px; width: auto; height: 270px; object-fit: contain;
          pointer-events: none; z-index: 1;
          filter: drop-shadow(0 18px 26px rgba(0,0,0,.5));
          animation: ehFloat 6s ease-in-out infinite;
        }
        .eh-cutout--left  { left: 1.5rem; }
        .eh-cutout--right { right: 1.5rem; animation-duration: 6.6s; animation-delay: .8s; }
        .eh-pill {
          display: inline-flex; align-items: center; gap: .45rem; padding: .32rem .9rem;
          border-radius: 999px; background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.22);
          color: #FDE68A; font-size: .7rem; font-weight: 600; letter-spacing: .07em; text-transform: uppercase;
          backdrop-filter: blur(6px);
        }
        .eh-quick-link {
          display: inline-flex; align-items: center; gap: .4rem; padding: .5rem .95rem;
          border-radius: .65rem; font-size: .78rem; font-weight: 600; text-decoration: none;
          color: #fff; background: rgba(255,255,255,.1); border: 1px solid rgba(255,255,255,.2);
          transition: all .25s cubic-bezier(.3,1.4,.5,1);
        }
        .eh-quick-link:hover { background: #fff; color: #8B1A1A; transform: translateY(-2px); box-shadow: 0 10px 20px -8px rgba(0,0,0,.4); }

        /* ── KPI cards ── */
        .eh-kpi {
          position: relative; overflow: hidden; border-radius: 1.1rem; padding: 1.25rem;
          background: rgba(255,255,255,.9); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
          border: 1px solid rgba(255,255,255,.8);
          box-shadow: 0 14px 32px -10px rgba(17,24,39,.16), 0 1px 2px rgba(17,24,39,.04);
          transition: transform .3s cubic-bezier(.22,1,.36,1), box-shadow .3s;
        }
        .eh-kpi::before {
          content: ""; position: absolute; left: 0; right: 0; top: 0; height: 3px;
          background: var(--accent);
        }
        .eh-kpi::after {
          content: ""; position: absolute; top: 0; bottom: 0; left: 0; width: 40%;
          background: linear-gradient(90deg, transparent, rgba(255,255,255,.7), transparent);
          transform: translateX(-120%) skewX(-18deg); pointer-events: none;
        }
        .eh-kpi:hover { transform: translateY(-6px); box-shadow: 0 22px 40px -12px color-mix(in srgb, var(--accent) 35%, transparent); }
        .eh-kpi:hover::after { animation: ehShine .9s ease; }
        .eh-kpi-icon {
          width: 42px; height: 42px; border-radius: .8rem; display: flex; align-items: center; justify-content: center;
          color: #fff; background: linear-gradient(135deg, var(--accent), color-mix(in srgb, var(--accent) 65%, #000));
          box-shadow: 0 8px 16px -6px var(--accent);
          transition: transform .35s cubic-bezier(.3,1.6,.5,1);
        }
        .eh-kpi:hover .eh-kpi-icon { transform: rotate(-8deg) scale(1.1); }
        .eh-kpi-bg-icon {
          position: absolute; right: -10px; bottom: -14px; color: var(--accent); opacity: .07; pointer-events: none;
        }

        /* ── Panels ── */
        .eh-panel {
          background: #fff; border: 1px solid #E8E2D9; border-radius: 1.1rem;
          box-shadow: 0 4px 20px -8px rgba(26,26,26,.06);
          transition: box-shadow .25s ease, transform .25s ease;
        }
        .eh-panel:hover { box-shadow: 0 14px 30px -10px rgba(26,26,26,.12); }
        .eh-panel-head { display: flex; align-items: center; justify-content: space-between; gap: 1rem; margin-bottom: 1rem; }
        .eh-panel-title { display: flex; align-items: center; gap: .7rem; }
        .eh-panel-icon {
          width: 34px; height: 34px; border-radius: .65rem; display: flex; align-items: center; justify-content: center;
          color: var(--accent, #8B1A1A); background: color-mix(in srgb, var(--accent, #8B1A1A) 12%, transparent);
        }
        .eh-tag {
          font-size: .64rem; font-weight: 700; letter-spacing: .07em; text-transform: uppercase;
          padding: .25rem .6rem; border-radius: 999px; white-space: nowrap;
          color: var(--accent, #8B1A1A); background: color-mix(in srgb, var(--accent, #8B1A1A) 10%, transparent);
        }

        .eh-quick {
          position: relative; overflow: hidden; padding: 1rem 1.2rem; display: flex; align-items: center;
          justify-content: space-between; gap: .75rem;
        }
        .eh-quick:hover { transform: translateX(4px); }
        .eh-quick--accent { border-left: 4px solid #8B1A1A; background: linear-gradient(to right, #fff5f5, #fff); }

        /* ── Lists ── */
        .eh-list-item {
          display: flex; align-items: center; gap: .85rem; padding: .7rem .6rem; border-radius: .7rem;
          transition: background .2s, transform .2s;
        }
        .eh-list-item:hover { background: #FBF5F2; transform: translateX(3px); }
        .eh-date-chip {
          flex-shrink: 0; width: 46px; border-radius: .65rem; overflow: hidden; text-align: center;
          border: 1px solid #F1D9D3; background: #fff; box-shadow: 0 3px 8px -4px rgba(139,26,26,.3);
        }
        .eh-date-chip-month { display: block; font-size: .58rem; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; color: #fff; background: #8B1A1A; padding: .15rem 0; }
        .eh-date-chip-day   { display: block; font-size: 1.05rem; font-weight: 800; color: #1f2937; padding: .15rem 0 .2rem; }
        .eh-avatar {
          width: 34px; height: 34px; border-radius: 999px; flex-shrink: 0; display: flex; align-items: center; justify-content: center;
          font-size: .78rem; font-weight: 700; color: #fff;
          background: linear-gradient(135deg, #8B1A1A, #c2410c); box-shadow: 0 3px 8px rgba(139,26,26,.28);
        }

        /* ── Bookings table ── */
        .eh-table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: .83rem; }
        .eh-table thead th {
          padding: .85rem 1.25rem; text-align: left; font-size: .67rem; font-weight: 700; color: #fff;
          text-transform: uppercase; letter-spacing: .09em; white-space: nowrap;
          background: linear-gradient(135deg, #A32424 0%, #8B1A1A 45%, #661111 100%);
        }
        .eh-table thead th .eh-th { display: inline-flex; align-items: center; gap: .45rem; }
        .eh-table tbody tr { animation: ehRise .5s cubic-bezier(.2,.7,.2,1) both; }
        .eh-table tbody td { padding: .85rem 1.25rem; border-top: 1px solid #F1ECE5; transition: background .2s, box-shadow .2s; white-space: nowrap; }
        .eh-table tbody tr:first-child td { border-top: none; }
        .eh-table tbody tr:nth-child(even) td { background: #FDFBF8; }
        .eh-table tbody tr:hover td { background: #FBF1EE; }
        .eh-table tbody tr:hover td:first-child { box-shadow: inset 3px 0 0 #8B1A1A; }

        .eh-empty { padding: 2rem 1rem; text-align: center; color: #9ca3af; font-size: .82rem; }
        .eh-empty-icon { display: inline-flex; width: 2.6rem; height: 2.6rem; border-radius: 999px; align-items: center; justify-content: center; color: #8B1A1A; background: rgba(139,26,26,.08); margin-bottom: .5rem; }

        @media (max-width: 1100px) {
          .eh-cutout { height: 195px; opacity: .4; }
          .eh-kpi-grid { grid-template-columns: repeat(2, 1fr) !important; }
          .eh-analytics-grid, .eh-split-grid { grid-template-columns: 1fr !important; }
        }
        @media (max-width: 640px) {
          .eh-cutout { display: none; }
          .eh-hero { padding: 1.75rem 1.1rem 5.5rem; }
          .eh-kpi-grid { grid-template-columns: 1fr !important; padding: 0 .75rem !important; }
        }
        @media (prefers-reduced-motion: reduce) {
          .eh-cutout, .eh-rise, .eh-table tbody tr, .eh-hero-ring { animation: none !important; }
        }
      </style>

      <div style="padding: 1.5rem; display: flex; flex-direction: column; gap: 1.75rem; max-width: 1440px; margin: 0 auto;">
        <%!-- ══ HERO ══ --%>
        <div style="position: relative;">
          <div class="eh-hero">
            <div class="eh-hero-dots"></div>
            <div class="eh-hero-ring" style="width: 420px; height: 420px; left: 50%; top: -230px; transform: translateX(-50%);"></div>
            <div class="eh-hero-ring" style="width: 620px; height: 620px; left: 50%; top: -330px; transform: translateX(-50%); animation-delay: 1.2s;"></div>

            <img
              src={~p"/images/admin/left-girl.png"}
              alt=""
              aria-hidden="true"
              class="eh-cutout eh-cutout--left"
            />
            <img
              src={~p"/images/admin/right-boy.png"}
              alt=""
              aria-hidden="true"
              class="eh-cutout eh-cutout--right"
            />

            <div
              class="eh-rise"
              style="position: relative; z-index: 2; text-align: center; max-width: 580px; margin: 0 auto;"
            >
              <span class="eh-pill">
                <span style="width: 6px; height: 6px; border-radius: 50%; background: #34D399; animation: ehPulse 2s infinite;">
                </span>
                Today · {Calendar.strftime(local_today(), "%A, %d %B %Y")}
              </span>

              <h1 style="font-size: 1.9rem; font-weight: 800; color: #fff; letter-spacing: -0.02em; margin: 0.95rem 0 0.45rem;">
                {greeting()}, {admin_name(@current_scope)}
              </h1>
              <p style="font-size: 0.9rem; color: rgba(255,255,255,0.78); line-height: 1.55;">
                Travellers, trips, ceremonies and stays across Zambia — all in one view.
              </p>

              <div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 0.55rem; margin-top: 1.25rem;">
                <a href="/admin/trips" class="eh-quick-link">
                  <.icon name="hero-map" class="size-4" /> Trips
                </a>
                <a href="/admin/events" class="eh-quick-link">
                  <.icon name="hero-sparkles" class="size-4" /> Events
                </a>
                <a href="/admin/sites" class="eh-quick-link">
                  <.icon name="hero-globe-alt" class="size-4" /> Sites
                </a>
                <a href="/admin/bookings" class="eh-quick-link">
                  <.icon name="hero-bookmark" class="size-4" /> Bookings
                </a>
              </div>
            </div>

            <svg class="eh-hero-wave" viewBox="0 0 1440 70" preserveAspectRatio="none" aria-hidden="true">
              <path
                d="M0,40 C240,75 480,5 720,30 C960,55 1200,15 1440,38 L1440,70 L0,70 Z"
                fill="rgba(255,255,255,0.06)"
              />
            </svg>
          </div>

          <%!-- Floating KPI cards --%>
          <div
            class="eh-kpi-grid"
            style="position: relative; z-index: 3; margin-top: -4.5rem; padding: 0 1.5rem;
                   display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem;"
          >
            <.stat_card
              label="Total Users"
              value={@stats.users}
              trend="Registered explorers"
              icon="hero-users"
              color="#8B1A1A"
              delay={0}
            />
            <.stat_card
              label="Trips Planned"
              value={@stats.trips}
              trend={"#{@stats.upcoming_trips} upcoming"}
              icon="hero-map"
              color="#0d9488"
              delay={80}
            />
            <.stat_card
              label="Total Bookings"
              value={@stats.bookings}
              trend={"#{@stats.pending_bookings} awaiting confirmation"}
              icon="hero-bookmark"
              color="#d97706"
              delay={160}
            />
            <.stat_card
              label="Accommodations"
              value={@stats.accommodations}
              trend="Partner stays"
              icon="hero-building-office-2"
              color="#2563eb"
              delay={240}
            />
          </div>
        </div>

        <%!-- ══ ANALYTICS ══ --%>
        <div
          class="eh-analytics-grid"
          style="display: grid; grid-template-columns: 1.6fr 1.1fr 0.85fr; gap: 1.15rem; align-items: stretch;"
        >
          <div
            class="eh-panel eh-rise"
            style="--accent: #8B1A1A; padding: 1.35rem; display: flex; flex-direction: column; animation-delay: 120ms;"
          >
            <.panel_head
              icon="hero-chart-bar"
              title="Bookings Trajectory"
              sub="Monthly check-in volume this year"
              tag="Bar view"
            />
            <div
              id="bookings-bar-chart"
              phx-hook="BookingsBarChart"
              data-monthly={Jason.encode!(@monthly_bookings)}
              style="flex: 1; min-height: 215px;"
            >
            </div>
          </div>

          <div
            class="eh-panel eh-rise"
            style="--accent: #d97706; padding: 1.35rem; display: flex; flex-direction: column; animation-delay: 200ms;"
          >
            <.panel_head
              icon="hero-chart-pie"
              title="Status Distribution"
              sub="Share by reservation state"
              tag="Pie share"
            />
            <div
              id="bookings-pie-chart"
              phx-hook="BookingsPieChart"
              data-status={Jason.encode!(@status_breakdown)}
              style="flex: 1; min-height: 215px;"
            >
            </div>
          </div>

          <div
            class="eh-rise"
            style="display: flex; flex-direction: column; gap: 0.9rem; justify-content: space-between; animation-delay: 280ms;"
          >
            <.quick_stat
              label="Tourist Sites"
              value={@stats.sites}
              sub="Destinations listed"
              icon="hero-globe-alt"
            />
            <.quick_stat
              label="Ceremonies & Events"
              value={@stats.events}
              sub={"#{@stats.upcoming_events} upcoming"}
              icon="hero-sparkles"
            />
            <.quick_stat
              label="Pending Approvals"
              value={@stats.pending_bookings}
              sub="Awaiting confirmation"
              icon="hero-clock"
              accent
            />
          </div>
        </div>

        <%!-- ══ EVENTS + TRIPS ══ --%>
        <div class="eh-split-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.15rem;">
          <div class="eh-panel eh-rise" style="--accent: #7c3aed; padding: 1.35rem; animation-delay: 320ms;">
            <.panel_head
              icon="hero-sparkles"
              title="Upcoming Ceremonies & Events"
              sub="Next on the cultural calendar"
              tag="Calendar"
            />
            <%= if @upcoming_events == [] do %>
              <.empty_state icon="hero-calendar" message="No upcoming events scheduled" />
            <% else %>
              <div style="display: flex; flex-direction: column; gap: 0.15rem;">
                <%= for event <- @upcoming_events do %>
                  <div class="eh-list-item">
                    <div class="eh-date-chip">
                      <span class="eh-date-chip-month">{Calendar.strftime(event.start_date, "%b")}</span>
                      <span class="eh-date-chip-day">{Calendar.strftime(event.start_date, "%d")}</span>
                    </div>
                    <div style="min-width: 0; flex: 1;">
                      <p style="font-size: 0.85rem; font-weight: 700; color: #1f2937; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                        {event.title}
                      </p>
                      <p style="font-size: 0.74rem; color: #9ca3af; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                        {event.type || "Event"} · {event.location || "Location TBC"}
                      </p>
                    </div>
                    <span class="eh-tag" style="--accent: #7c3aed;">{days_until(event.start_date)}</span>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <div class="eh-panel eh-rise" style="--accent: #0d9488; padding: 1.35rem; animation-delay: 400ms;">
            <.panel_head
              icon="hero-map"
              title="Recently Planned Trips"
              sub="Latest journeys created by visitors"
              tag="Live"
            />
            <%= if @recent_trips == [] do %>
              <.empty_state icon="hero-map" message="No trips planned yet" />
            <% else %>
              <div style="display: flex; flex-direction: column; gap: 0.15rem;">
                <%= for trip <- @recent_trips do %>
                  <div class="eh-list-item">
                    <div class="eh-avatar" style="background: linear-gradient(135deg, #0d9488, #115e59);">
                      <.icon name="hero-map-pin" class="size-4" />
                    </div>
                    <div style="min-width: 0; flex: 1;">
                      <p style="font-size: 0.85rem; font-weight: 700; color: #1f2937; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                        {trip.title || "Untitled trip"}
                      </p>
                      <p style="font-size: 0.74rem; color: #9ca3af; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                        {trip.starting_district || "—"} → {trip.destination_district || "Open route"}
                        · {trip.traveller_count || 1} traveller{if trip.traveller_count != 1, do: "s"}
                      </p>
                    </div>
                    <span class="eh-tag" style="--accent: #0d9488;">
                      {if trip.start_date, do: Calendar.strftime(trip.start_date, "%d %b"), else: "Undated"}
                    </span>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- ══ RECENT BOOKINGS ══ --%>
        <div class="eh-panel eh-rise" style="overflow: hidden; animation-delay: 460ms;">
          <div style="padding: 1.15rem 1.4rem; display: flex; align-items: center; justify-content: space-between; gap: 1rem; background: #FCFBF9; border-bottom: 1px solid #E8E2D9;">
            <div class="eh-panel-title">
              <div class="eh-panel-icon"><.icon name="hero-bookmark" class="size-4" /></div>
              <div>
                <h2 style="font-size: 0.95rem; font-weight: 700; color: #1f2937;">Recent Bookings</h2>
                <p style="font-size: 0.74rem; color: #9ca3af;">Latest 8 reservations across all properties</p>
              </div>
            </div>
            <a href="/admin/bookings" class="eh-tag" style="text-decoration: none; padding: 0.45rem 0.9rem;">
              View all →
            </a>
          </div>

          <div style="overflow-x: auto;">
            <table class="eh-table">
              <thead>
                <tr>
                  <th><span class="eh-th"><.icon name="hero-user" class="size-3.5" /> Guest</span></th>
                  <th>
                    <span class="eh-th"><.icon name="hero-building-office-2" class="size-3.5" /> Accommodation</span>
                  </th>
                  <th><span class="eh-th"><.icon name="hero-arrow-down-tray" class="size-3.5" /> Check-in</span></th>
                  <th><span class="eh-th"><.icon name="hero-arrow-up-tray" class="size-3.5" /> Check-out</span></th>
                  <th><span class="eh-th"><.icon name="hero-banknotes" class="size-3.5" /> Total</span></th>
                  <th><span class="eh-th"><.icon name="hero-signal" class="size-3.5" /> Status</span></th>
                </tr>
              </thead>
              <tbody>
                <%= for {booking, i} <- Enum.with_index(@recent_bookings) do %>
                  <tr style={"animation-delay: #{500 + i * 40}ms;"}>
                    <td>
                      <div style="display: flex; align-items: center; gap: 0.65rem;">
                        <div class="eh-avatar">{initials(booking.user_name)}</div>
                        <span style="color: #1f2937; font-weight: 600;">{booking.user_name}</span>
                      </div>
                    </td>
                    <td><span style="color: #4b5563; font-weight: 500;">{booking.accommodation_name}</span></td>
                    <td><span style="color: #6b7280;">{format_date(booking.check_in)}</span></td>
                    <td><span style="color: #6b7280;">{format_date(booking.check_out)}</span></td>
                    <td><span style="color: #111827; font-weight: 700;">{money(booking.total_price)}</span></td>
                    <td>
                      <span style={booking_badge_style(booking.status)}>
                        <span style="width: 6px; height: 6px; border-radius: 999px; background: currentColor;"></span>
                        {String.capitalize(booking.status || "unknown")}
                      </span>
                    </td>
                  </tr>
                <% end %>

                <%= if @recent_bookings == [] do %>
                  <tr>
                    <td colspan="6"><.empty_state icon="hero-inbox" message="No bookings yet" /></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layouts.admin_app>
    """
  end

  # ── Components ───────────────────────────────────────────────────────

  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :trend, :string, required: true
  attr :icon, :string, required: true
  attr :color, :string, default: "#8B1A1A"
  attr :delay, :integer, default: 0

  defp stat_card(assigns) do
    ~H"""
    <div class="eh-kpi eh-rise" style={"--accent: #{@color}; animation-delay: #{@delay}ms;"}>
      <span class="eh-kpi-bg-icon"><.icon name={@icon} class="size-24" /></span>
      <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.85rem;">
        <span style="font-size: 0.72rem; font-weight: 700; color: #4b5563; text-transform: uppercase; letter-spacing: 0.05em;">
          {@label}
        </span>
        <div class="eh-kpi-icon"><.icon name={@icon} class="size-5" /></div>
      </div>
      <p style="font-size: 2rem; font-weight: 800; color: #111827; line-height: 1.05; margin-bottom: 0.35rem; letter-spacing: -0.02em;">
        {format_number(@value)}
      </p>
      <p style={"font-size: 0.72rem; font-weight: 600; color: #{@color}; display: inline-flex; align-items: center; gap: 0.3rem;"}>
        <.icon name="hero-arrow-trending-up" class="size-3.5" /> {@trend}
      </p>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :sub, :string, required: true
  attr :icon, :string, required: true
  attr :accent, :boolean, default: false

  defp quick_stat(assigns) do
    ~H"""
    <div class={["eh-panel eh-quick", @accent && "eh-quick--accent"]}>
      <div>
        <p style="font-size: 0.73rem; font-weight: 600; color: #6b7280; margin-bottom: 0.2rem;">{@label}</p>
        <p style={"font-size: 1.6rem; font-weight: 800; line-height: 1.1; margin-bottom: 0.2rem; color: #{if @accent, do: "#8B1A1A", else: "#111827"};"}>
          {format_number(@value)}
        </p>
        <p style="font-size: 0.71rem; color: #9ca3af;">{@sub}</p>
      </div>
      <div
        class="eh-kpi-icon"
        style={"--accent: #{if @accent, do: "#8B1A1A", else: "#6b7280"};"}
      >
        <.icon name={@icon} class="size-5" />
      </div>
    </div>
    """
  end

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :sub, :string, required: true
  attr :tag, :string, default: nil

  defp panel_head(assigns) do
    ~H"""
    <div class="eh-panel-head">
      <div class="eh-panel-title">
        <div class="eh-panel-icon"><.icon name={@icon} class="size-4" /></div>
        <div>
          <h2 style="font-size: 0.92rem; font-weight: 700; color: #1f2937;">{@title}</h2>
          <p style="font-size: 0.74rem; color: #9ca3af;">{@sub}</p>
        </div>
      </div>
      <span :if={@tag} class="eh-tag">{@tag}</span>
    </div>
    """
  end

  attr :icon, :string, required: true
  attr :message, :string, required: true

  defp empty_state(assigns) do
    ~H"""
    <div class="eh-empty">
      <span class="eh-empty-icon"><.icon name={@icon} class="size-5" /></span>
      <p>{@message}</p>
    </div>
    """
  end

  # ── Formatting helpers ───────────────────────────────────────────────

  # Zambia is UTC+2 all year (no daylight saving), so no tz database is needed.
  defp local_now, do: NaiveDateTime.add(NaiveDateTime.utc_now(), 2 * 3600, :second)
  defp local_today, do: NaiveDateTime.to_date(local_now())

  defp greeting do
    case local_now().hour do
      h when h < 12 -> "Good morning"
      h when h < 17 -> "Good afternoon"
      _ -> "Good evening"
    end
  end

  defp admin_name(%{user: %{name: name}}) when is_binary(name) and name != "",
    do: name |> String.split() |> List.first()

  defp admin_name(_), do: "Admin"

  defp initials(nil), do: "?"

  defp initials(name) do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map_join(&String.first/1)
    |> String.upcase()
  end

  defp days_until(%NaiveDateTime{} = dt), do: days_until(NaiveDateTime.to_date(dt))
  defp days_until(%DateTime{} = dt), do: days_until(DateTime.to_date(dt))

  defp days_until(%Date{} = date) do
    case Date.diff(date, local_today()) do
      0 -> "Today"
      1 -> "Tomorrow"
      n -> "In #{n} days"
    end
  end

  defp format_date(nil), do: "—"
  defp format_date(%Date{} = d), do: Calendar.strftime(d, "%d %b %Y")
  defp format_date(%NaiveDateTime{} = d), do: Calendar.strftime(d, "%d %b %Y")
  defp format_date(other), do: to_string(other)

  defp money(nil), do: "—"

  defp money(%Decimal{} = value),
    do: "ZMW " <> Number.Delimit.number_to_delimited(Decimal.to_float(value), precision: 2)

  defp money(value) when is_number(value),
    do: "ZMW " <> Number.Delimit.number_to_delimited(value, precision: 2)

  defp format_number(value) when is_integer(value),
    do: Number.Delimit.number_to_delimited(value, precision: 0)

  defp format_number(value), do: value

  defp booking_badge_style(status) do
    {bg, fg, border} =
      case status do
        "confirmed" -> {"#f0fdf4", "#15803d", "#bbf7d0"}
        "pending" -> {"#fffbeb", "#b45309", "#fde68a"}
        "cancelled" -> {"#fef2f2", "#dc2626", "#fecaca"}
        _ -> {"#f3f4f6", "#6b7280", "#e5e7eb"}
      end

    "display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.22rem 0.7rem; " <>
      "border-radius: 999px; font-size: 0.72rem; font-weight: 600; " <>
      "background: #{bg}; color: #{fg}; border: 1px solid #{border};"
  end

  # ── Data loaders ─────────────────────────────────────────────────────

  defp load_stats do
    %{
      users: safe_count("users"),
      trips: safe_count("trips"),
      upcoming_trips: safe_count("trips", where: "start_date >= CURRENT_DATE"),
      bookings: safe_count("bookings"),
      pending_bookings: safe_count("bookings", where: "status = 'pending'"),
      accommodations: safe_count("accommodations"),
      sites: safe_count("sites"),
      events: safe_count("events"),
      upcoming_events: safe_count("events", where: "start_date >= NOW()")
    }
  end

  defp safe_count(table, opts \\ []) do
    where = Keyword.get(opts, :where)

    sql =
      if where,
        do: "SELECT COUNT(*) FROM #{table} WHERE #{where}",
        else: "SELECT COUNT(*) FROM #{table}"

    case Repo.query(sql) do
      {:ok, %{rows: [[count]]}} -> count
      _ -> 0
    end
  end

  defp query_maps(sql) do
    case Repo.query(sql) do
      {:ok, %{columns: cols, rows: rows}} ->
        Enum.map(rows, fn row ->
          cols |> Enum.zip(row) |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        end)

      _ ->
        []
    end
  end

  defp load_recent_bookings do
    query_maps("""
    SELECT u.name AS user_name, a.name AS accommodation_name,
           b.check_in, b.check_out, b.total_price, b.status
    FROM bookings b
    JOIN users u          ON u.id = b.user_id
    JOIN accommodations a ON a.id = b.accommodation_id
    ORDER BY b.inserted_at DESC
    LIMIT 8
    """)
  end

  defp load_recent_trips do
    query_maps("""
    SELECT title, starting_district, destination_district, start_date, traveller_count
    FROM trips
    ORDER BY inserted_at DESC
    LIMIT 5
    """)
  end

  defp load_upcoming_events do
    query_maps("""
    SELECT title, type, location, start_date
    FROM events
    WHERE start_date >= NOW()
    ORDER BY start_date ASC
    LIMIT 5
    """)
  end

  defp monthly_booking_counts do
    sql = """
    SELECT EXTRACT(MONTH FROM check_in)::integer AS month, COUNT(*)::integer AS count
    FROM bookings
    WHERE EXTRACT(YEAR FROM check_in) = EXTRACT(YEAR FROM NOW())
    GROUP BY month
    ORDER BY month
    """

    base = Map.new(1..12, &{&1, 0})

    counts =
      case Repo.query(sql) do
        {:ok, %{rows: rows}} -> Map.new(rows, fn [m, c] -> {m, c} end)
        _ -> %{}
      end

    base
    |> Map.merge(counts)
    |> Enum.sort_by(fn {month, _} -> month end)
    |> Enum.map(fn {_month, count} -> count end)
  end

  defp booking_status_counts do
    sql = """
    SELECT LOWER(COALESCE(status, 'other')) AS status, COUNT(*)::integer AS count
    FROM bookings
    GROUP BY 1
    """

    defaults = %{"confirmed" => 0, "pending" => 0, "cancelled" => 0}

    counts =
      case Repo.query(sql) do
        {:ok, %{rows: rows}} -> Map.new(rows, fn [s, c] -> {s, c} end)
        _ -> %{}
      end

    Map.merge(defaults, counts)
  end
end
