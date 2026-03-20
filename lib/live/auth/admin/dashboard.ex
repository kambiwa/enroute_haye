defmodule EnrouteHayeWeb.Auth.Admin.Dashboard do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Repo
  alias EnrouteHaye.Accounts
  alias EnrouteHaye.Tourism   # adjust to your actual context modules

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
      <div class="p-6 space-y-6">

        <%!-- ══ WELCOME HEADER ══ --%>
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-xl font-bold text-gray-800">Dashboard</h1>
            <p class="text-sm text-gray-400 mt-0.5">
              Welcome back — here's what's happening today.
            </p>
          </div>
          <div class="text-sm text-gray-400">
            {Calendar.strftime(Date.utc_today(), "%B %d, %Y")}
          </div>
        </div>

        <%!-- ══ STAT CARDS ══ --%>
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <.stat_card
            label="Total Users"
            value={@stats.users}
            icon="hero-users"
            color="crimson"
          />
          <.stat_card
            label="Active Trips"
            value={@stats.trips}
            icon="hero-map"
            color="teal"
          />
          <.stat_card
            label="Bookings"
            value={@stats.bookings}
            icon="hero-bookmark"
            color="amber"
          />
          <.stat_card
            label="Accommodations"
            value={@stats.accommodations}
            icon="hero-building-office-2"
            color="blue"
          />
        </div>

        <%!-- ══ CHART + QUICK LINKS ROW ══ --%>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">

          <%!-- Bookings chart (spans 2 cols) --%>
          <div class="lg:col-span-2 bg-white border border-[#E8E2D9] rounded-xl p-5">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-sm font-semibold text-gray-700">Bookings this year</h2>
              <span class="text-xs text-gray-400">Monthly</span>
            </div>
            <div id="bookings-chart"
                 phx-hook="BookingsChart"
                 data-monthly={Jason.encode!(@monthly_bookings)}
                 class="h-48">
            </div>
          </div>

          <%!-- Quick stats column --%>
          <div class="space-y-4">
            <div class="bg-white border border-[#E8E2D9] rounded-xl p-5">
              <p class="text-xs text-gray-400 mb-1">Sites</p>
              <p class="text-2xl font-bold text-gray-800">{@stats.sites}</p>
              <p class="text-xs text-gray-400 mt-1">Tourist locations</p>
            </div>
            <div class="bg-white border border-[#E8E2D9] rounded-xl p-5">
              <p class="text-xs text-gray-400 mb-1">Events</p>
              <p class="text-2xl font-bold text-gray-800">{@stats.events}</p>
              <p class="text-xs text-gray-400 mt-1">Upcoming &amp; past</p>
            </div>
            <div class="bg-white border border-[#E8E2D9] rounded-xl p-5">
              <p class="text-xs text-gray-400 mb-1">Pending bookings</p>
              <p class="text-2xl font-bold text-[#8B1A1A]">{@stats.pending_bookings}</p>
              <p class="text-xs text-gray-400 mt-1">Awaiting confirmation</p>
            </div>
          </div>
        </div>

        <%!-- ══ RECENT BOOKINGS TABLE ══ --%>
        <div class="bg-white border border-[#E8E2D9] rounded-xl overflow-hidden">
          <div class="px-5 py-4 border-b border-[#E8E2D9] flex items-center justify-between">
            <h2 class="text-sm font-semibold text-gray-700">Recent bookings</h2>
            <a href={~p"/admin/bookings"}
               class="text-xs text-[#8B1A1A] hover:underline font-medium">
              View all →
            </a>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead>
                <tr class="bg-[#FAF8F5] text-left">
                  <th class="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Guest</th>
                  <th class="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Accommodation</th>
                  <th class="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Check-in</th>
                  <th class="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Check-out</th>
                  <th class="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Total</th>
                  <th class="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Status</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-[#E8E2D9]">
                <%= for booking <- @recent_bookings do %>
                  <tr class="hover:bg-[#FAF8F5] transition-colors">
                    <td class="px-5 py-3.5">
                      <div class="flex items-center gap-2.5">
                        <div class="w-7 h-7 rounded-full bg-[#8B1A1A]/10 flex items-center justify-center text-[#8B1A1A] text-xs font-bold shrink-0">
                          {String.first(booking.user_name)}
                        </div>
                        <span class="text-gray-700 font-medium">{booking.user_name}</span>
                      </div>
                    </td>
                    <td class="px-5 py-3.5 text-gray-600">{booking.accommodation_name}</td>
                    <td class="px-5 py-3.5 text-gray-500">{booking.check_in}</td>
                    <td class="px-5 py-3.5 text-gray-500">{booking.check_out}</td>
                    <td class="px-5 py-3.5 text-gray-700 font-medium">
                      ZMW {booking.total_price}
                    </td>
                    <td class="px-5 py-3.5">
                      <span class={booking_badge(booking.status)}>
                        {booking.status}
                      </span>
                    </td>
                  </tr>
                <% end %>

                <%= if Enum.empty?(@recent_bookings) do %>
                  <tr>
                    <td colspan="6" class="px-5 py-10 text-center text-gray-400 text-sm">
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

  # ── Stat card component ──────────────────────────────────────────────
  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :icon, :string, required: true
  attr :color, :string, default: "crimson"

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-white border border-[#E8E2D9] rounded-xl p-5 flex items-start gap-4">
      <div class={icon_bg(@color)}>
        <.icon name={@icon} class="size-5" />
      </div>
      <div class="min-w-0">
        <p class="text-xs text-gray-400 mb-0.5">{@label}</p>
        <p class="text-2xl font-bold text-gray-800">{@value}</p>
      </div>
    </div>
    """
  end

  defp icon_bg("crimson"), do: "w-10 h-10 rounded-lg bg-[#8B1A1A]/10 flex items-center justify-center text-[#8B1A1A] shrink-0"
  defp icon_bg("teal"),    do: "w-10 h-10 rounded-lg bg-teal-50 flex items-center justify-center text-teal-600 shrink-0"
  defp icon_bg("amber"),   do: "w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center text-amber-600 shrink-0"
  defp icon_bg("blue"),    do: "w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600 shrink-0"
  defp icon_bg(_),         do: "w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center text-gray-500 shrink-0"

  defp booking_badge("confirmed"), do: "inline-flex px-2 py-0.5 rounded-full text-xs font-semibold bg-green-50 text-green-700"
  defp booking_badge("pending"),   do: "inline-flex px-2 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700"
  defp booking_badge("cancelled"), do: "inline-flex px-2 py-0.5 rounded-full text-xs font-semibold bg-red-50 text-red-600"
  defp booking_badge(_),           do: "inline-flex px-2 py-0.5 rounded-full text-xs font-semibold bg-gray-100 text-gray-600"

  # ── Data loaders ─────────────────────────────────────────────────────
  # Replace these with real Repo queries once your contexts are set up.

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
      u.name          AS user_name,
      a.name          AS accommodation_name,
      b.check_in,
      b.check_out,
      b.total_price,
      b.status
    FROM bookings b
    JOIN users         u ON u.id = b.user_id
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

    base = Enum.map(1..12, &{&1, 0}) |> Map.new()

    counts =
      case Repo.query(sql) do
        {:ok, %{rows: rows}} ->
          Map.new(rows, fn [m, c] -> {m, c} end)
        _ ->
          %{}
      end

    # Merge so all 12 months always present
    Map.merge(base, counts)
    |> Enum.sort_by(fn {month, _} -> month end)
    |> Enum.map(fn {_month, count} -> count end)
  end
end
