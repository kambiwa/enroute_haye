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
      |> assign(:monthly_bookings, monthly_booking_counts())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin_app flash={@flash} current_page={:dashboard}>
      <div style="padding: 1.5rem; display: flex; flex-direction: column; gap: 1.5rem;">

        <div style="display: flex; align-items: center; justify-content: space-between;">
          <div>
            <h1 style="font-size: 1.1rem; font-weight: 700; color: #1a1a1a; margin-bottom: 0.2rem;">
              Dashboard
            </h1>
            <p style="font-size: 0.82rem; color: #9ca3af;">
              Welcome back — here's what's happening today.
            </p>
          </div>
          <span style="font-size: 0.8rem; color: #9ca3af;">
            {Calendar.strftime(Date.utc_today(), "%B %d, %Y")}
          </span>
        </div>

        <%!-- ══ STAT CARDS — 4 columns ══ --%>
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem;">
          <.stat_card label="Total Users"      value={@stats.users}          icon="hero-users"              color="#8B1A1A" />
          <.stat_card label="Active Trips"     value={@stats.trips}          icon="hero-map"                color="#0d9488" />
          <.stat_card label="Bookings"         value={@stats.bookings}       icon="hero-bookmark"           color="#d97706" />
          <.stat_card label="Accommodations"   value={@stats.accommodations} icon="hero-building-office-2"  color="#2563eb" />
        </div>

        <%!-- ══ CHART + QUICK STATS ══ --%>
        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1rem; align-items: start;">

          <%!-- Bookings chart — spans 2 cols --%>
          <div style="grid-column: span 2; background: #fff; border: 1px solid #E8E2D9;
                      border-top: 3px solid #8B1A1A; border-radius: 0.75rem; padding: 1.25rem;">
            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem;">
              <h2 style="font-size: 0.85rem; font-weight: 600; color: #374151;">Bookings this year</h2>
              <span style="font-size: 0.72rem; color: #9ca3af; letter-spacing: 0.08em; text-transform: uppercase;">Monthly</span>
            </div>
            <div id="bookings-chart"
                 phx-hook="BookingsChart"
                 data-monthly={Jason.encode!(@monthly_bookings)}
                 style="height: 180px;">
            </div>
          </div>

          <%!-- Quick stats — 1 col --%>
          <div style="display: flex; flex-direction: column; gap: 1rem;">
            <.quick_stat label="Sites"            value={@stats.sites}            sub="Tourist locations" />
            <.quick_stat label="Events"           value={@stats.events}           sub="Upcoming & past" />
            <.quick_stat label="Pending bookings" value={@stats.pending_bookings} sub="Awaiting confirmation" accent={true} />
          </div>

        </div>

        <%!-- ══ RECENT BOOKINGS TABLE ══ --%>
        <div style="background: #fff; border: 1px solid #E8E2D9; border-radius: 0.75rem; overflow: hidden;">

          <div style="padding: 1rem 1.25rem; border-bottom: 1px solid #E8E2D9;
                      display: flex; align-items: center; justify-content: space-between;">
            <h2 style="font-size: 0.85rem; font-weight: 600; color: #374151;">Recent bookings</h2>
            <a href={~p"/admin/bookings"}
               style="font-size: 0.75rem; color: #8B1A1A; font-weight: 500; text-decoration: none;"
               onmouseover="this.style.textDecoration='underline'"
               onmouseout="this.style.textDecoration='none'">
              View all →
            </a>
          </div>

          <div style="overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse; font-size: 0.83rem;">
              <thead>
                <tr style="background: #FAF8F5;">
                  <th style={th_style()}>Guest</th>
                  <th style={th_style()}>Accommodation</th>
                  <th style={th_style()}>Check-in</th>
                  <th style={th_style()}>Check-out</th>
                  <th style={th_style()}>Total</th>
                  <th style={th_style()}>Status</th>
                </tr>
              </thead>
              <tbody>
                <%= for booking <- @recent_bookings do %>
                  <tr style="border-top: 1px solid #E8E2D9;"
                      onmouseover="this.style.background='#FAF8F5'"
                      onmouseout="this.style.background='transparent'">
                    <td style={td_style()}>
                      <div style="display: flex; align-items: center; gap: 0.6rem;">
                        <div style="width: 28px; height: 28px; border-radius: 50%;
                                    background: rgba(139,26,26,0.1); color: #8B1A1A;
                                    display: flex; align-items: center; justify-content: center;
                                    font-size: 0.72rem; font-weight: 700; flex-shrink: 0;">
                          {String.first(booking.user_name)}
                        </div>
                        <span style="color: #374151; font-weight: 500;">{booking.user_name}</span>
                      </div>
                    </td>
                    <td style={td_style()}><span style="color: #4b5563;">{booking.accommodation_name}</span></td>
                    <td style={td_style()}><span style="color: #6b7280;">{booking.check_in}</span></td>
                    <td style={td_style()}><span style="color: #6b7280;">{booking.check_out}</span></td>
                    <td style={td_style()}><span style="color: #374151; font-weight: 500;">ZMW {booking.total_price}</span></td>
                    <td style={td_style()}>
                      <span style={booking_badge_style(booking.status)}>
                        {booking.status}
                      </span>
                    </td>
                  </tr>
                <% end %>

                <%= if Enum.empty?(@recent_bookings) do %>
                  <tr>
                    <td colspan="6" style="padding: 2.5rem; text-align: center; color: #9ca3af; font-size: 0.85rem;">
                      No bookings yet
                    </td>
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

  # ── Stat card ────────────────────────────────────────────────────────
  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :icon,  :string,  required: true
  attr :color, :string,  default: "#8B1A1A"

  defp stat_card(assigns) do
    ~H"""
    <div style="background: #fff; border: 1px solid #E8E2D9; border-radius: 0.75rem;
                padding: 1.25rem; display: flex; align-items: flex-start; gap: 1rem;">
      <div style={"width: 40px; height: 40px; border-radius: 0.5rem; flex-shrink: 0;
                  background: #{@color}18; color: #{@color};
                  display: flex; align-items: center; justify-content: center;"}>
        <.icon name={@icon} class="size-5" />
      </div>
      <div>
        <p style="font-size: 0.72rem; color: #9ca3af; margin-bottom: 0.2rem;">{@label}</p>
        <p style="font-size: 1.6rem; font-weight: 700; color: #111827; line-height: 1;">{@value}</p>
      </div>
    </div>
    """
  end

  # ── Quick stat ───────────────────────────────────────────────────────
  attr :label,  :string,  required: true
  attr :value,  :integer, required: true
  attr :sub,    :string,  required: true
  attr :accent, :boolean, default: false

  defp quick_stat(assigns) do
    ~H"""
    <div style="background: #fff; border: 1px solid #E8E2D9; border-radius: 0.75rem; padding: 1.1rem 1.25rem;">
      <p style="font-size: 0.72rem; color: #9ca3af; margin-bottom: 0.25rem;">{@label}</p>
      <p style={"font-size: 1.6rem; font-weight: 700; line-height: 1; margin-bottom: 0.25rem; color: #{if @accent, do: "#8B1A1A", else: "#111827"}"}}>
        {@value}
      </p>
      <p style="font-size: 0.72rem; color: #9ca3af;">{@sub}</p>
    </div>
    """
  end

  # ── Table style helpers ──────────────────────────────────────────────
  defp th_style,
    do: "padding: 0.65rem 1.25rem; text-align: left; font-size: 0.68rem; font-weight: 600;
         color: #9ca3af; text-transform: uppercase; letter-spacing: 0.08em; white-space: nowrap;"

  defp td_style,
    do: "padding: 0.8rem 1.25rem;"

  defp booking_badge_style("confirmed"),
    do: "display: inline-flex; padding: 0.2rem 0.6rem; border-radius: 999px; font-size: 0.72rem;
         font-weight: 600; background: #f0fdf4; color: #15803d;"

  defp booking_badge_style("pending"),
    do: "display: inline-flex; padding: 0.2rem 0.6rem; border-radius: 999px; font-size: 0.72rem;
         font-weight: 600; background: #fffbeb; color: #b45309;"

  defp booking_badge_style("cancelled"),
    do: "display: inline-flex; padding: 0.2rem 0.6rem; border-radius: 999px; font-size: 0.72rem;
         font-weight: 600; background: #fef2f2; color: #dc2626;"

  defp booking_badge_style(_),
    do: "display: inline-flex; padding: 0.2rem 0.6rem; border-radius: 999px; font-size: 0.72rem;
         font-weight: 600; background: #f3f4f6; color: #6b7280;"

  # ── Data loaders ─────────────────────────────────────────────────────

  defp load_stats do
    %{
      users:            safe_count("users"),
      trips:            safe_count("trips"),
      bookings:         safe_count("bookings"),
      pending_bookings: safe_count("bookings", where: "status = 'pending'"),
      accommodations:   safe_count("accommodations"),
      sites:            safe_count("sites"),
      events:           safe_count("events")
    }
  end

  defp safe_count(table, opts \\ []) do
    where = Keyword.get(opts, :where)
    sql   = if where, do: "SELECT COUNT(*) FROM #{table} WHERE #{where}", else: "SELECT COUNT(*) FROM #{table}"
    case Repo.query(sql) do
      {:ok, %{rows: [[count]]}} -> count
      _                         -> 0
    end
  end

  defp load_recent_bookings do
    sql = """
    SELECT
      u.name           AS user_name,
      a.name           AS accommodation_name,
      b.check_in,
      b.check_out,
      b.total_price,
      b.status
    FROM bookings b
    JOIN users          u ON u.id = b.user_id
    JOIN accommodations a ON a.id = b.accommodation_id
    ORDER BY b.inserted_at DESC
    LIMIT 8
    """

    case Repo.query(sql) do
      {:ok, %{columns: cols, rows: rows}} ->
        Enum.map(rows, fn row ->
          cols
          |> Enum.zip(row)
          |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        end)
      _ ->
        []
    end
  end

  defp monthly_booking_counts do
    sql = """
    SELECT
      EXTRACT(MONTH FROM check_in)::integer AS month,
      COUNT(*)::integer                     AS count
    FROM bookings
    WHERE EXTRACT(YEAR FROM check_in) = EXTRACT(YEAR FROM NOW())
    GROUP BY month
    ORDER BY month
    """

    base   = Enum.map(1..12, &{&1, 0}) |> Map.new()
    counts =
      case Repo.query(sql) do
        {:ok, %{rows: rows}} -> Map.new(rows, fn [m, c] -> {m, c} end)
        _                    -> %{}
      end

    Map.merge(base, counts)
    |> Enum.sort_by(fn {month, _} -> month end)
    |> Enum.map(fn {_month, count} -> count end)
  end
end
