defmodule EnrouteHayeWeb.Auth.Road.Index do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHayeWeb.Datatable.Table
  alias EnrouteHaye.Schema.Road
  alias EnrouteHaye.Context.CxtRoad
  alias EnrouteHayeWeb.Pagination
  alias EnrouteHayeWeb.PaginationComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Road Operators")
      |> assign(:data_loader, false)
      |> assign(:data, [])
      |> assign(:data_pagenations, [])
      |> assign(filter_expanded: false)
      |> assign(:status_filter, "")
      |> assign(:search_filter, "")
      |> assign(:road, %Road{})
      |> Pagination.order_by_composer()
      |> Pagination.i_search_composer()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(params: %{})
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    id = String.to_integer(id)
    road = CxtRoad.get_road_operator!(id)
    socket
    |> assign(:page_title, "Edit Road Operator")
    |> assign(:road, road)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Road Operator")
    |> assign(:road, %Road{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Road Operators")
    |> assign(:road, nil)
    |> fetch_filtered_roads()
  end

  @impl true
  def handle_info(
        {EnrouteHayeWeb.Road.FormComponent, {:saved, _road}},
        socket
      ) do
    {:noreply, fetch_filtered_roads(socket)}
  end

  @impl true
  def handle_event("add_road_operator", _params, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "New Road Operator")
     |> assign(:road, %Road{})
     |> assign(:live_action, :new)}
  end

    @impl true
    def handle_event("edit", %{"id" => id}, socket) do
      road =
        id
        |> String.to_integer()
        |> CxtRoad.get_road_operator!()

      {:noreply,
      socket
      |> assign(:road, road)
      |> assign(:page_title, "Edit Road Operator")
      |> assign(:live_action, :edit)}
    end

  @impl true
  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :live_action, :index)}
  end

  @impl true
  def handle_event("toggle-filter", _, socket) do
    {:noreply, assign(socket, filter_expanded: !socket.assigns.filter_expanded)}
  end

  @impl true
  def handle_event("filter", %{"filter" => filters}, socket) do
    {:noreply,
     socket
     |> assign(:status_filter, filters["status_filter"])
     |> assign(:search_filter, filters["search_filter"])
     |> fetch_filtered_roads()}
  end

  defp fetch_filtered_roads(socket) do
    filters = %{
      search_filter: socket.assigns.search_filter,
      status_filter: socket.assigns.status_filter
    }

    data =
      CxtRoad.list_bus_operators(
        Pagination.create_table_params(socket, socket.assigns.params),
        filters
      )

    socket
    |> assign(:data, data.entries)
    |> assign(:data_pagenations, Map.drop(data, [:entries]))
    |> assign(data_loader: false)
  end

  # ── Render ─────────────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin_app flash={@flash} current_scope={@current_scope} current_page={:roads}>
      <div style="padding: 1.5rem; display: flex; flex-direction: column; gap: 1.5rem;">

        <%!-- ══ PAGE HEADER ══ --%>
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <div>
            <h1 style="font-size: 1.1rem; font-weight: 700; color: #1a1a1a; margin-bottom: 0.2rem;">
              Road Operators
            </h1>
            <p style="font-size: 0.82rem; color: #9ca3af;">
              Manage road operator listings and their route details.
            </p>
          </div>

          <div style="display: flex; align-items: center; gap: 0.75rem;">
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

            <button
              phx-click="add_road_operator"
              style="display: inline-flex; align-items: center; gap: 0.4rem;
                     padding: 0.45rem 1rem; font-size: 0.82rem; font-weight: 500;
                     color: #fff; background: #8B1A1A; border: none;
                     border-radius: 0.5rem; cursor: pointer; transition: opacity 0.15s;"
              onmouseover="this.style.opacity='0.88'"
              onmouseout="this.style.opacity='1'"
            >
              <.icon name="hero-plus" class="size-4" /> New Road Operator
            </button>
          </div>
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
                    placeholder="Search operators, routes…"
                    value={@search_filter}
                  />
                </div>
                <div style="display: flex; flex-direction: column; gap: 0.35rem;">
                  <label style="font-size: 0.75rem; font-weight: 500; color: #374151;">Status</label>
                  <.input
                    type="select"
                    name="filter[status_filter]"
                    prompt="All"
                    options={[{"Active", "active"}, {"Inactive", "inactive"}]}
                    value={@status_filter}
                  />
                </div>
              </div>
            </.form>
          </div>
        <% end %>

        <%!-- ══ TABLE CARD ══ --%>
        <div style="background: #fff; border: 1px solid #E8E2D9; border-radius: 0.75rem; overflow: hidden;">

          <div style="padding: 1rem 1.25rem; border-bottom: 1px solid #E8E2D9;">
            <h2 style="font-size: 0.85rem; font-weight: 600; color: #374151;">All Road Operators</h2>
          </div>

          <Table.table id="tbl_roads" rows={@data}>
            <:col :let={road} label="Operator">
              <span style="color: #374151; font-weight: 500;">{road.operator}</span>
            </:col>
            <:col :let={road} label="Route">
              <span style="color: #6b7280;">{road.route}</span>
            </:col>
            <:col :let={road} label="Departure">
              <span style="color: #6b7280;">{road.departure_point}</span>
            </:col>
            <:col :let={road} label="Arrival">
              <span style="color: #6b7280;">{road.arrival_point}</span>
            </:col>
            <:col :let={road} label="Dep. Time">
              <span style="color: #6b7280;">
                {if road.departure_time,
                  do: Calendar.strftime(road.departure_time, "%H:%M"),
                  else: "—"}
              </span>
            </:col>
            <:col :let={road} label="Price">
              <span style="color: #6b7280;">
                {if road.price, do: "$#{road.price}", else: "—"}
              </span>
            </:col>
            <:col :let={road} label="Contact">
              <span style="color: #6b7280;">{road.operator_contact || "—"}</span>
            </:col>

            <:action :let={road}>
              <button
                phx-click="edit"
                phx-value-id={road.id}
                style="display: inline-flex; align-items: center; gap: 0.3rem;
                       padding: 0.25rem 0.65rem; font-size: 0.75rem; font-weight: 500;
                       color: #8B1A1A; background: rgba(139,26,26,0.08);
                       border: none; border-radius: 0.4rem; cursor: pointer; transition: background 0.15s;"
                onmouseover="this.style.background='rgba(139,26,26,0.15)'"
                onmouseout="this.style.background='rgba(139,26,26,0.08)'"
              >
                <.icon name="hero-pencil-square" class="size-3" /> Edit
              </button>
            </:action>
          </Table.table>

          <%= if @data_loader do %>
            <div style="padding: 2.5rem; text-align: center;">
              <svg xmlns="http://www.w3.org/2000/svg"
                   style="width: 2rem; height: 2rem; color: #8B1A1A; animation: spin 1s linear infinite; margin: 0 auto;"
                   fill="none" viewBox="0 0 24 24">
                <circle style="opacity: 0.25;" cx="12" cy="12" r="10"
                        stroke="currentColor" stroke-width="4"/>
                <path style="opacity: 0.75;" fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962
                         7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
              </svg>
            </div>
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
        <%= if @live_action in [:new, :edit] do %>
          <.modal
            id={"crud-road-modal-#{(@road && @road.id) || :new}"}
            show
            on_cancel={JS.push("close")}
          >
            <.live_component
              module={EnrouteHayeWeb.Road.FormComponent}
              id={(@road && @road.id) || :new}
              title={@page_title}
              action={@live_action}
              road={@road}
              patch={~p"/admin/roads"}
            />
          </.modal>
        <% end %>

      </div>
    </Layouts.admin_app>
    """
  end
end
