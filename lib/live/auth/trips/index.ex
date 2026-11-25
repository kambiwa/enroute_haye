defmodule EnrouteHayeWeb.Auth.Trips.Index do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Context.CxtRoad
  alias EnrouteHaye.Trips.Admin, as: TripsAdmin
  alias EnrouteHaye.Trips.BudgetCalculator
  alias EnrouteHayeWeb.Datatable.Table
  alias EnrouteHayeWeb.Pagination

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Trips")
      |> assign(:data_loader, false)
      |> assign(:data, [])
      |> assign(:data_pagenations, [])
      |> assign(filter_expanded: false)
      |> assign(:timing_filter, "")
      |> assign(:search_filter, "")
      |> assign(:provinces, CxtRoad.list_provinces())
      |> reset_modal()
      |> Pagination.order_by_composer()
      |> Pagination.i_search_composer()

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(params: %{})
     |> fetch_filtered_trips()}
  end

  # ── Events ───────────────────────────────────────────────────────────

  @impl true
  def handle_event("view_trip", %{"id" => id}, socket) do
    {:noreply, socket |> load_trip(id) |> assign(:mode, :view)}
  end

  # From a table row: load the trip, then open the form.
  def handle_event("edit_trip", %{"id" => id}, socket) do
    {:noreply, socket |> load_trip(id) |> open_form()}
  end

  # From the view modal's "Edit Trip" button: the trip is already loaded.
  def handle_event("edit_trip", _params, socket) do
    {:noreply, open_form(socket)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, :mode, :view)}
  end

  def handle_event("close", _params, socket) do
    {:noreply, reset_modal(socket)}
  end

  def handle_event("validate", %{"trip" => attrs}, socket) do
    attrs =
      attrs
      |> clear_district_on_province_change("starting", socket.assigns.form)
      |> clear_district_on_province_change("destination", socket.assigns.form)
      |> put_end_date()

    changeset =
      socket.assigns.trip
      |> TripsAdmin.change_trip(attrs)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, as: :trip))
     |> assign_district_options(attrs["starting_province"], attrs["destination_province"])}
  end

  def handle_event("save", %{"trip" => attrs}, socket) do
    case TripsAdmin.update_trip(socket.assigns.trip, put_end_date(attrs)) do
      {:ok, trip} ->
        {:noreply,
         socket
         |> load_trip(trip.id)
         |> assign(:mode, :view)
         |> fetch_filtered_trips()
         |> put_flash(:info, "Trip updated.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: :trip))
         |> put_flash(:error, "Please correct the highlighted fields.")}
    end
  end

  def handle_event("toggle-filter", _, socket) do
    {:noreply, assign(socket, filter_expanded: !socket.assigns.filter_expanded)}
  end

  def handle_event("filter", %{"filter" => filters}, socket) do
    {:noreply,
     socket
     |> assign(:timing_filter, filters["timing_filter"] || "")
     |> assign(:search_filter, filters["search_filter"] || "")
     |> fetch_filtered_trips()}
  end

  # ── State helpers ────────────────────────────────────────────────────

  defp reset_modal(socket) do
    socket
    |> assign(:trip, nil)
    |> assign(:budget, nil)
    |> assign(:mode, nil)
    |> assign(:form, nil)
    |> assign(:starting_districts, [])
    |> assign(:destination_districts, [])
  end

  defp load_trip(socket, id) do
    trip = TripsAdmin.get_trip!(id)

    socket
    |> assign(:trip, trip)
    |> assign(:budget, BudgetCalculator.calculate(trip))
  end

  defp open_form(socket) do
    trip = socket.assigns.trip

    socket
    |> assign(:mode, :edit)
    |> assign(:form, to_form(TripsAdmin.change_trip(trip), as: :trip))
    |> assign_district_options(trip.starting_province, trip.destination_province)
  end

  defp assign_district_options(socket, starting_province, destination_province) do
    socket
    |> assign(:starting_districts, districts_for(starting_province))
    |> assign(:destination_districts, districts_for(destination_province))
  end

  defp districts_for(province) when province in [nil, ""], do: []
  defp districts_for(province), do: CxtRoad.list_districts(province)

  # When the province changes, the old district no longer belongs to it.
  defp clear_district_on_province_change(attrs, prefix, form) do
    province_key = "#{prefix}_province"
    district_key = "#{prefix}_district"
    previous = Phoenix.HTML.Form.input_value(form, String.to_existing_atom(province_key))

    if to_string(previous || "") != to_string(attrs[province_key] || ""),
      do: Map.put(attrs, district_key, ""),
      else: attrs
  end

  defp put_end_date(attrs) do
    with {:ok, start_date} <- Date.from_iso8601(attrs["start_date"] || ""),
         {days, ""} when days > 0 <- Integer.parse(attrs["duration_days"] || "") do
      Map.put(attrs, "end_date", start_date |> Date.add(days - 1) |> Date.to_iso8601())
    else
      _ -> attrs
    end
  end

  defp fetch_filtered_trips(socket) do
    filters = %{
      search_filter: socket.assigns.search_filter,
      timing_filter: socket.assigns.timing_filter
    }

    data =
      TripsAdmin.list_trips(
        Pagination.create_table_params(socket, socket.assigns.params),
        filters
      )

    socket
    |> assign(:data, data.entries)
    |> assign(:data_pagenations, Map.drop(data, [:entries]))
    |> assign(data_loader: false)
  end

  # ── Formatting helpers ───────────────────────────────────────────────

  def money(%Decimal{} = value),
    do: "ZMW " <> Number.Delimit.number_to_delimited(Decimal.to_float(value), precision: 2)

  def money(value) when is_number(value),
    do: "ZMW " <> Number.Delimit.number_to_delimited(value, precision: 2)

  def money(_), do: "—"

  def format_date(nil), do: "—"
  def format_date(%Date{} = date), do: Calendar.strftime(date, "%d %b %Y")

  def date_range(%{start_date: nil}), do: "Dates not set"

  def date_range(%{start_date: start_date, end_date: end_date}),
    do: "#{format_date(start_date)} – #{format_date(end_date)}"

  def place(district, province) do
    [district, province]
    |> Enum.reject(&(is_nil(&1) or &1 == ""))
    |> case do
      [] -> "—"
      parts -> Enum.join(parts, ", ")
    end
  end

  def timing(%{start_date: nil}), do: {"Undated", "#9ca3af"}

  def timing(%{start_date: start_date, end_date: end_date}) do
    today = Date.utc_today()

    cond do
      Date.compare(start_date, today) == :gt -> {"Upcoming", "#2563eb"}
      end_date && Date.compare(end_date, today) == :lt -> {"Past", "#6b7280"}
      true -> {"In progress", "#16a34a"}
    end
  end

  def transport_modes([]), do: "Not selected"

  def transport_modes(segments),
    do: segments |> Enum.map(&String.replace(&1.mode, "_", " ")) |> Enum.uniq() |> Enum.join(", ")

  defp end_date_hint(form) do
    case Phoenix.HTML.Form.input_value(form, :end_date) do
      %Date{} = date -> format_date(date)
      value when is_binary(value) and value != "" -> value
      _ -> "Set a start date and duration"
    end
  end

  # ── Render ───────────────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin_app flash={@flash} current_scope={@current_scope} current_page={:trips}>
      <div style="padding: 1.5rem; display: flex; flex-direction: column; gap: 1.5rem;">
        <%!-- ══ PAGE HEADER ══ --%>
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <div>
            <h1 style="font-size: 1.1rem; font-weight: 700; color: #1a1a1a; margin-bottom: 0.2rem;">
              Trips
            </h1>
            <p style="font-size: 0.82rem; color: #9ca3af;">
              Trips planned by visitors, including saved drafts.
            </p>
          </div>

          <button
            phx-click="toggle-filter"
            style="display: inline-flex; align-items: center; gap: 0.4rem;
                   padding: 0.45rem 1rem; font-size: 0.82rem; font-weight: 500;
                   color: #374151; background: #fff; border: 1px solid #E8E2D9;
                   border-radius: 0.5rem; cursor: pointer; transition: background 0.15s;"
            onmouseover="this.style.background='#FAF8F5'"
            onmouseout="this.style.background='#fff'"
          >
            <.icon name="hero-funnel" class="size-4" /> Filter
          </button>
        </div>

        <%!-- ══ FILTER PANEL ══ --%>
        <%= if @filter_expanded do %>
          <div style="background: #fff; border: 1px solid #E8E2D9;
                      border-top: 3px solid #8B1A1A; border-radius: 0.75rem; padding: 1.25rem;">
            <p style="font-size: 0.75rem; font-weight: 600; color: #374151;
                      text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 1rem;">
              Filters
            </p>
            <.form for={%{}} as={:filter} phx-change="filter">
              <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem;">
                <div style="display: flex; flex-direction: column; gap: 0.35rem;">
                  <label style="font-size: 0.75rem; font-weight: 500; color: #374151;">Search</label>
                  <.input
                    name="filter[search_filter]"
                    placeholder="Title, traveller or district..."
                    value={@search_filter}
                    phx-debounce="300"
                  />
                </div>

                <div style="display: flex; flex-direction: column; gap: 0.35rem;">
                  <label style="font-size: 0.75rem; font-weight: 500; color: #374151;">Timing</label>
                  <.input
                    type="select"
                    name="filter[timing_filter]"
                    prompt="All"
                    options={[
                      {"Upcoming", "upcoming"},
                      {"In progress", "ongoing"},
                      {"Past", "past"},
                      {"Undated", "undated"}
                    ]}
                    value={@timing_filter}
                  />
                </div>
              </div>
            </.form>
          </div>
        <% end %>

        <%!-- ══ TABLE CARD ══ --%>
        <div style="background: #fff; border: 1px solid #E8E2D9; border-radius: 0.75rem; overflow: hidden;">
          <div style="padding: 1rem 1.25rem; border-bottom: 1px solid #E8E2D9;">
            <h2 style="font-size: 0.85rem; font-weight: 600; color: #374151;">All Trips</h2>
          </div>

          <Table.table id="tbl_trips" rows={@data}>
            <:col :let={trip} label="Title" icon="hero-map" cell_icon>
              <span style="color: #374151; font-weight: 600;">{trip.title || "Untitled"}</span>
            </:col>
            <:col :let={trip} label="Traveller" icon="hero-user">
              <span style="color: #6b7280;">{trip.traveller_name || "—"}</span>
            </:col>
            <:col :let={trip} label="Route" icon="hero-arrows-right-left">
              <span style="color: #6b7280;">
                {place(trip.starting_district, trip.starting_province)} → {place(
                  trip.destination_district,
                  trip.destination_province
                )}
              </span>
            </:col>
            <:col :let={trip} label="Dates" icon="hero-calendar-days">
              <span style="color: #6b7280;">{date_range(trip)}</span>
            </:col>
            <:col :let={trip} label="Travellers" icon="hero-user-group" align="center">
              <span style="color: #6b7280;">{trip.traveller_count || "—"}</span>
            </:col>
            <:col :let={trip} label="Timing" icon="hero-clock">
              <% {label, color} = timing(trip) %>
              <span style={"display: inline-flex; align-items: center; gap: 0.35rem;
                            padding: 0.2rem 0.6rem; border-radius: 999px; font-size: 0.72rem;
                            font-weight: 600; color: #{color}; background: #{color}14;"}>
                <span style={"width: 0.4rem; height: 0.4rem; border-radius: 999px; background: #{color};"}>
                </span>
                {label}
              </span>
            </:col>
            <:action :let={trip}>
              <div style="display: inline-flex; gap: 0.4rem;">
                <button phx-click="view_trip" phx-value-id={trip.id} style={row_btn_style()}>
                  <.icon name="hero-eye" class="size-3" /> View
                </button>
                <button phx-click="edit_trip" phx-value-id={trip.id} style={row_btn_style()}>
                  <.icon name="hero-pencil-square" class="size-3" /> Edit
                </button>
              </div>
            </:action>
          </Table.table>

          <%= if @data == [] and not @data_loader do %>
            <p style="padding: 2rem; text-align: center; font-size: 0.85rem; color: #9ca3af;">
              No trips match these filters.
            </p>
          <% end %>

          <div style="border-top: 1px solid #E8E2D9;">
            <.live_component
              module={EnrouteHayeWeb.PaginationComponent}
              id="PaginationComponent"
              params={@params}
              pagination_data={@data_pagenations}
            />
          </div>
        </div>

        <%!-- ══ MODAL ══ --%>
        <%= if @trip && @mode do %>
          <.modal id={"trip-modal-#{@trip.id}"} show on_cancel={JS.push("close")}>
            <%= if @mode == :view do %>
              <.trip_view trip={@trip} budget={@budget} />
            <% else %>
              <.trip_form
                form={@form}
                provinces={@provinces}
                starting_districts={@starting_districts}
                destination_districts={@destination_districts}
              />
            <% end %>
          </.modal>
        <% end %>
      </div>
    </Layouts.admin_app>
    """
  end

  # ── Modal: view mode ─────────────────────────────────────────────────

  attr :trip, :map, required: true
  attr :budget, :map, default: nil

  defp trip_view(assigns) do
    ~H"""
    <div>
      <.modal_header
        icon="hero-map"
        title={@trip.title || "Untitled trip"}
        subtitle={@trip.description || "Trip details as planned by the visitor."}
      />

      <div style="padding: 1.25rem 1.25rem 0; display: flex; flex-direction: column; gap: 1.4rem;">
        <div>
          <.section_label>Trip info</.section_label>
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem;">
            <.detail label="Traveller">{@trip.traveller_name || "—"}</.detail>
            <.detail label="Travellers">{@trip.traveller_count || "—"}</.detail>
            <.detail label="Target budget">{money(@trip.budget_estimate)}</.detail>
            <.detail label="Transport">{transport_modes(@trip.transport_segments)}</.detail>
          </div>
        </div>

        <div>
          <.section_label>Route & schedule</.section_label>
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem;">
            <.detail label="Starting from">
              {place(@trip.starting_district, @trip.starting_province)}
            </.detail>
            <.detail label="Destination">
              {place(@trip.destination_district, @trip.destination_province)}
            </.detail>
            <.detail label="Dates">{date_range(@trip)}</.detail>
            <.detail label="Duration">
              {if @trip.duration_days, do: "#{@trip.duration_days} days", else: "—"}
            </.detail>
          </div>
        </div>

        <div>
          <.section_label>Selections</.section_label>
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem;">
            <.detail label="Ceremony / event">
              {if @trip.selected_event, do: @trip.selected_event.title, else: "Not selected"}
            </.detail>
            <.detail label="Accommodation">
              {case List.first(@trip.accommodation_selections) do
                nil ->
                  "Not selected"

                sel ->
                  "#{sel.accommodation.name} (#{format_date(sel.check_in)} – #{format_date(sel.check_out)})"
              end}
            </.detail>
            <.detail label="Food">
              {case @trip.food_selections do
                [] -> "None selected"
                sels -> Enum.map_join(sels, ", ", & &1.food.name)
              end}
            </.detail>
            <.detail label="Music">
              {case @trip.audio_selections do
                [] -> "None selected"
                sels -> Enum.map_join(sels, ", ", & &1.audio.title)
              end}
            </.detail>
          </div>
        </div>

        <div>
          <.section_label>Destinations ({length(@trip.trip_stops)})</.section_label>
          <%= if @trip.trip_stops == [] do %>
            <p style="font-size: 0.82rem; color: #9ca3af;">No destinations selected.</p>
          <% else %>
            <ol style="display: flex; flex-direction: column; gap: 0.4rem; padding-left: 1.1rem; list-style: decimal;">
              <%= for stop <- @trip.trip_stops do %>
                <li style="font-size: 0.82rem; color: #374151;">
                  <strong>{stop.site.name}</strong>
                  <span style="color: #9ca3af;"> · Day {stop.day_number || "—"}</span>
                  <%= if stop.notes && stop.notes != "" do %>
                    <span style="color: #6b7280;"> — {stop.notes}</span>
                  <% end %>
                </li>
              <% end %>
            </ol>
          <% end %>
        </div>

        <%= if @budget do %>
          <div>
            <.section_label>Estimated cost · {@budget.currency}</.section_label>
            <div style="background: #FAF8F5; border: 1px solid #E8E2D9; border-radius: 0.6rem; padding: 0.9rem 1rem;">
              <p style="font-size: 1.1rem; font-weight: 700; color: #8B1A1A;">
                {money(@budget.known_total)}
              </p>
              <p style="font-size: 0.75rem; color: #6b7280; margin-top: 0.2rem;">
                {if @budget.total_complete?,
                  do: "Includes all selected priced items.",
                  else: "Incomplete: some prices or selections are unavailable."}
                · Per traveller: {money(@budget.per_traveller)}
              </p>
            </div>
          </div>
        <% end %>
      </div>

      <.modal_footer>
        <button type="button" phx-click="close" style={secondary_btn_style()}>Close</button>
        <button type="button" phx-click="edit_trip" style={primary_btn_style()}>
          <.icon name="hero-pencil-square" class="size-4" /> Edit Trip
        </button>
      </.modal_footer>
    </div>
    """
  end

  # ── Modal: edit mode ─────────────────────────────────────────────────

  attr :form, :any, required: true
  attr :provinces, :list, required: true
  attr :starting_districts, :list, required: true
  attr :destination_districts, :list, required: true

  defp trip_form(assigns) do
    ~H"""
    <.form for={@form} id="trip-admin-form" phx-change="validate" phx-submit="save">
      <.modal_header
        icon="hero-map"
        title="Edit Trip"
        subtitle="Update the trip details. Destinations and selections are managed by the visitor."
      />

      <div style="padding: 1.25rem 1.25rem 0; display: flex; flex-direction: column; gap: 1.4rem;">
        <div>
          <.section_label>Trip info</.section_label>
          <.input field={@form[:title]} type="text" label="Trip Title" />
          <.input field={@form[:description]} type="textarea" label="Trip Notes" />
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;">
            <.input field={@form[:traveller_name]} type="text" label="Traveller Name" />
            <.input
              field={@form[:traveller_count]}
              type="number"
              label="Number of Travellers"
              min="1"
              max="100"
            />
          </div>
          <.input
            field={@form[:budget_estimate]}
            type="number"
            label="Target Budget (ZMW)"
            min="0"
            step="0.01"
          />
        </div>

        <div>
          <.section_label>Route</.section_label>
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;">
            <.input
              field={@form[:starting_province]}
              type="select"
              label="Starting Province"
              prompt="Choose province"
              options={@provinces}
            />
            <.input
              field={@form[:starting_district]}
              type="select"
              label="Starting District"
              prompt="Choose district"
              options={@starting_districts}
            />
            <.input
              field={@form[:destination_province]}
              type="select"
              label="Destination Province"
              prompt="Optional"
              options={@provinces}
            />
            <.input
              field={@form[:destination_district]}
              type="select"
              label="Destination District"
              prompt="Optional"
              options={@destination_districts}
            />
          </div>
        </div>

        <div>
          <.section_label>Schedule</.section_label>
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;">
            <.input field={@form[:start_date]} type="date" label="Start Date" />
            <.input
              field={@form[:duration_days]}
              type="number"
              label="Duration (days)"
              min="1"
              max="365"
            />
          </div>
          <p style="font-size: 0.75rem; color: #6b7280;">
            End date: <strong>{end_date_hint(@form)}</strong>
          </p>
        </div>
      </div>

      <.modal_footer>
        <button type="button" phx-click="cancel_edit" style={secondary_btn_style()}>
          Cancel
        </button>
        <button type="submit" phx-disable-with="Saving..." style={primary_btn_style()}>
          <.icon name="hero-check" class="size-4" /> Save Changes
        </button>
      </.modal_footer>
    </.form>
    """
  end

  # ── Shared modal pieces (match the Edit Event modal) ─────────────────

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil

  defp modal_header(assigns) do
    ~H"""
    <div style="display: flex; align-items: center; gap: 0.85rem; background: #8B1A1A;
                border-radius: 0.75rem 0.75rem 0 0; padding: 1.1rem 1.25rem;">
      <div style="display: flex; align-items: center; justify-content: center;
                  width: 2.25rem; height: 2.25rem; border-radius: 0.5rem;
                  background: rgba(255,255,255,0.15); color: #fff; flex-shrink: 0;">
        <.icon name={@icon} class="size-5" />
      </div>
      <div style="min-width: 0;">
        <h2 style="font-size: 1rem; font-weight: 700; color: #fff;">{@title}</h2>
        <%= if @subtitle do %>
          <p style="font-size: 0.78rem; color: rgba(255,255,255,0.8); margin-top: 0.1rem;
                    overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
            {@subtitle}
          </p>
        <% end %>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  defp section_label(assigns) do
    ~H"""
    <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.85rem;">
      <span style="width: 2rem; height: 1px; background: #8B1A1A;"></span>
      <span style="font-size: 0.72rem; font-weight: 700; letter-spacing: 0.1em;
                   text-transform: uppercase; color: #8B1A1A;">
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end

  slot :inner_block, required: true

  defp modal_footer(assigns) do
    ~H"""
    <div style="display: flex; justify-content: flex-end; gap: 0.6rem;
                margin: 1.5rem 1.25rem 0; padding-top: 1rem; border-top: 1px solid #E8E2D9;">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :label, :string, required: true
  slot :inner_block, required: true

  defp detail(assigns) do
    ~H"""
    <div style="background: #FAF8F5; border: 1px solid #E8E2D9; border-radius: 0.5rem; padding: 0.6rem 0.75rem;">
      <p style="font-size: 0.7rem; font-weight: 600; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.06em;">
        {@label}
      </p>
      <p style="font-size: 0.82rem; color: #374151; margin-top: 0.15rem;">
        {render_slot(@inner_block)}
      </p>
    </div>
    """
  end

  defp row_btn_style,
    do:
      "display: inline-flex; align-items: center; gap: 0.3rem; padding: 0.25rem 0.65rem; " <>
        "font-size: 0.75rem; font-weight: 500; color: #8B1A1A; background: rgba(139,26,26,0.08); " <>
        "border: none; border-radius: 0.4rem; cursor: pointer;"

  defp primary_btn_style,
    do:
      "display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.6rem 1.25rem; " <>
        "font-size: 0.85rem; font-weight: 600; color: #fff; background: #8B1A1A; " <>
        "border: none; border-radius: 0.6rem; cursor: pointer;"

  defp secondary_btn_style,
    do:
      "display: inline-flex; align-items: center; padding: 0.6rem 1.25rem; " <>
        "font-size: 0.85rem; font-weight: 500; color: #374151; background: #fff; " <>
        "border: 1px solid #E8E2D9; border-radius: 0.6rem; cursor: pointer;"
end
